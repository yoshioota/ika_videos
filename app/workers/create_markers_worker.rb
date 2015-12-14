class CreateMarkersWorker
  include Sidekiq::Worker
  sidekiq_options unique: :while_executing
  sidekiq_options queue: :create_markers

  def initialize
    @concurrency_scale = 10_000
    @gc_timing = 10
  end

  def perform(capture_id)
    return unless @capture = Capture.find_by_id(capture_id)
    @capture.start_end(:create_markers) { create_markers_total_frames! }
    CreateVideosWorker.perform_async(capture_id)
  end

  def create_markers_total_frames!
    # 大量のフレーム数が来る可能性があるので少しづつ渡す。
    (0...@capture.total_frames).to_enum.each_slice(Settings.concurrency * @concurrency_scale).with_index do |total_frame_array, idx|
      create_marker_frame(total_frame_array)
      gc_check(idx)
    end
  end

  def create_marker_frame(total_frame_array)
    calc = ->(total_frame) do
      Capture::AnalyzeFrames.new(capture: @capture, verbose: true).analyze_by_total_frame(total_frame)
    end

    if false
      total_frame_array.each(&calc)
    else
      Parallel.map(total_frame_array, in_processes: Settings.concurrency, &calc)
    end
  end

  def gc_check(idx)
    return unless (idx % @gc_timing).zero?
    GC.start
  end
end
