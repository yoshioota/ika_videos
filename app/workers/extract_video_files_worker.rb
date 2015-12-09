class ExtractVideoFilesWorker
  include Sidekiq::Worker
  sidekiq_options unique: :while_executing
  sidekiq_options queue: :extract_video_files

  def perform(capture_id)
    return unless capture = Capture.find_by_id(capture_id)
    extract_all(capture)
    update_playlist(capture)
  end

  def extract_all(capture)
    capture.videos.order(:start_frame).each do |video|
      FfmpegUtil.extract_movie(
          input_file: capture.full_path,
          start_frame: video.start_frame,
          end_frame: video.end_frame,
          output_file: video.output_file_path)
    end
  end

  def update_playlist(capture)
    videos = capture.videos.where.not(started_at: nil)
    dates_videos = videos.group_by{|video| video.started_at.to_date }
    dates_videos.each do |date, videos|
      playlist = Playlist.where(date_on: date).first
      videos.each do |video|
        playlist.playlists_videos.where(video_id: video.id).first_or_create
      end
      PlaylistsVideo::Reorder.new(playlist).perform
    end
  end
end
