class CreateVideosWorker
  include Sidekiq::Worker
  sidekiq_options unique: :while_executing
  sidekiq_options queue: :create_videos

  def perform(capture_id)
    return unless @capture = Capture.find_by_id(capture_id)
    @capture.start_end(:analyze_videos) { create_videos }
    ExtractVideoFilesWorker.new.perform(capture_id)
  end

  def create_videos
    group_videos.each do |video_params|
      video = @capture.videos.where(
          start_frame: video_params[:black].total_frame,
          end_frame: video_params[:finish].total_frame)
          .first_or_initialize
      video.started_at = @capture.started_at + video_params[:black].total_frame / 60
      video.ended_at = @capture.started_at + video_params[:finish].total_frame / 60
      video.total_frames = video.end_frame - video.start_frame
      video.file_name = "#{video.started_at.strftime('%Y%m%d-%H%M%S')}.mp4"
      video.save!

      analyze_rule_and_stage(video)
      analyze_game_result(video)
      analyze_kill_death(video)
    end
  end

  # TODO: 移動する
  def analyze_rule_and_stage(video)
    capture = video.capture
    stage_min_score = Float::INFINITY
    maybe_stage = nil

    rule_min_score = Float::INFINITY
    maybe_rule = nil

    (1..3).each do |sec|
      (0..59).step(10) do |frame|
        image_path = capture.get_frame_image_file_path_total_frame(video.start_frame + ((sec * 60) + frame))
        af = Splatoon::AnalyzeRuleAndStage.new(image_path)
        if stage = af.stage
          if stage[:min_score] < stage_min_score
            maybe_stage = stage
            stage_min_score = stage[:min_score]
          end
        end

        if rule = af.rule
          if rule[:min_score] < rule_min_score
            maybe_rule = rule
            rule_min_score = rule[:min_score]
          end
        end
      end
    end

    # puts "video id #{video.id} rule #{maybe_rule.pretty_inspect} stage #{maybe_stage.pretty_inspect}"
    video.game_rule  = maybe_rule[:rule_name] if maybe_rule
    video.game_stage = maybe_stage[:stage_name] if maybe_stage
    video.save!
  end

  # TODO: 移動する
  def analyze_game_result(video)
    capture = video.capture
    result_min_score = Float::INFINITY
    maybe_result = nil

    (7..10).each do |sec|
      (0..59).step(3) do |frame|
        image_path = capture.get_frame_image_file_path_total_frame(video.end_frame + ((sec * 60) + frame))
        af = Splatoon::AnalyzeGameResult.new(image_path)
        if game_result = af.game_result
          if game_result[:min_score] < result_min_score
            maybe_result = game_result
            result_min_score = game_result[:min_score]
          end
        end
      end
    end

    # puts "video id #{video.id} game_result #{maybe_result.pretty_inspect}"

    video.game_result = maybe_result[:game_result] if maybe_result
    video.save!
  end


  # TODO: 移動する
  def analyze_kill_death(video)
    capture = video.capture
    worker = CreateFrameFilesWorker.new(capture)

    kd = nil
    (14..19).each do |sec|
      (0..59).step(10) do |frame|
        total_frame = video.end_frame + ((sec * 60) + frame)
        worker.make_frame(total_frame, 1)
        image_path = capture.get_frame_image_file_path_total_frame(total_frame, 1)
        af = Splatoon::AnalyzeKillDeath.new(image_path)
        next unless kill_death = af.kill_death
        next unless num = af.number

        break if kd = kill_death[num]
      end
      break if kd
    end

    #
    # # puts "video id #{video.id} rule #{maybe_rule.pretty_inspect} stage #{maybe_stage.pretty_inspect}"
    if kd
      video.kills  = kd[0]
      video.deaths = kd[1]
    end
    video.save!
  end
  def group_videos
    finishes = fetch_markers('finish', 50_000_000)
    whites = fetch_markers('white', 200_000)
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
    videos.select { |video_params| video_params[:black] && video_params[:white] && video_params[:finish] }
  end

  def fetch_markers(type, threshold = 100_000, grouping = 60)
    @capture
        .markers
        .where(marker_type: type)
        .where('min_score < ?', threshold)
        .order(:total_frame)
        .group_by { |marker| marker.total_frame / grouping }
        .map do |key, markers|
      markers.sort_by { |marker| marker.min_score }.first
    end
  end
end
