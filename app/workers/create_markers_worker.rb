class CreateMarkersWorker
  include Sidekiq::Worker
  sidekiq_options unique: :while_executing
  sidekiq_options queue: :create_markers

  def perform(capture_id)
    return unless @capture = Capture.find_by_id(capture_id)
    @capture.start_end(:create_markers) do
      # create_markers_min!
      create_markers_total_frames!
    end
    CreateVideosWorker.new.perform(capture_id)
  end

  def create_markers_total_frames!
    total_frame_array = (0...@capture.total_frames).to_a
    create_marker_frame(total_frame_array)
  end

  def create_marker_frame(total_frame_array)
    calc = ->(total_frame) do
      Capture::AnalyzeFrames.new(capture: @capture, verbose: false).analyze_by_total_frame(total_frame)
    end

    if false
      total_frame_array.each(&calc)
    else
      Parallel.map(total_frame_array, in_processes: Settings.concurrency, &calc)
    end
  end
end
