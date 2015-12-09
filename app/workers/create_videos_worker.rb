class CreateVideosWorker
  include Sidekiq::Worker
  sidekiq_options unique: :while_executing
  sidekiq_options queue: :create_videos

  def perform(capture_id)
    return unless @capture = Capture.find_by_id(capture_id)
    @capture.start_end :analyze_videos do
      create
    end
    ExtractVideoFilesWorker.new.perform(capture_id)
  end

  def create
    videos = group_videos
    videos.each do |video_params|
      video = @capture.videos.where(
          start_frame: video_params[:black].total_frame,
          end_frame:   video_params[:finish].total_frame)
          .first_or_initialize
      video.started_at = @capture.started_at + video_params[:black].total_frame / 60
      video.ended_at   = @capture.started_at + video_params[:finish].total_frame / 60
      video.total_frames = video.end_frame - video.start_frame
      video.file_name = "#{video.started_at.strftime('%Y%m%d-%H%M%S')}.mp4"
      video.save!
    end
  end

  def group_videos
    finishes = fetch_markers('finish', 50_000_000)
    whites = fetch_markers('white', 2_000)
    blacks = fetch_markers('black', 2_000_000)

    videos = []

    markers = (finishes + whites + blacks).sort_by(&:total_frame).reverse
    markers.each do |marker|
      case marker.marker_type
      when 'finish'
        videos << {
            finish: marker
        }
      when 'white'
        next unless videos.last
        videos.last[:white] = marker
      when 'black'
        next unless videos.last
        next unless videos.last[:white]
        next if videos.last[:black]
        videos.last[:black] = marker
      end
    end
    videos.select{|video_params| video_params[:black] && video_params[:white] && video_params[:finish]}
  end

  def fetch_markers(type, threshold = 100_000, grouping = 60)
    @capture
        .markers
        .where(marker_type: type)
        .where('min_score < ?', threshold)
        .order(:total_frame)
        .group_by{|marker| marker.total_frame / grouping}
        .map do |key, markers|
      markers.sort_by{|marker| marker.min_score.to_f }.first
    end
  end
end
