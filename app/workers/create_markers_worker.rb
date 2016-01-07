class CreateMarkersWorker
  include Sidekiq::Worker
  sidekiq_options unique: :while_executing
  sidekiq_options queue: :create_markers

  def initialize
    @concurrency_scale = 100
    @gc_timing = 1
    @use_parallel = Settings.use_parallel
  end

  def perform(capture_id)
    return unless @capture = Capture.find_by_id(capture_id)

    @analyze_frames = Capture::AnalyzeFrames.new(capture: @capture, verbose: true)
    @capture.start_end(:create_markers) { create_markers_total_frames! }
    CreateVideosWorker.perform_async(capture_id)
  end

  def create_markers_total_frames!
    # 大量のフレーム数が来る可能性があるので少しづつ渡す。
    (0...@capture.total_frames).step(6).to_enum.each_slice(Settings.concurrency * @concurrency_scale).with_index do |total_frame_array, idx|
      create_marker_frame(total_frame_array)
      gc_check(idx)
    end
  end

  def create_marker_frame(total_frame_array)
    calc = ->(total_frame) do
      @analyze_frames.analyze_by_total_frame(total_frame)
    end

    if @use_parallel
      Parallel.map(total_frame_array, in_processes: Settings.concurrency, &calc)
    else
      total_frame_array.each(&calc)
    end
  end

  # FIXME: TODO: GCのタイミングをメモリが圧迫したら行なうようにする。
  def gc_check(idx)
    return unless (idx % @gc_timing).zero?
    GC.start
  end
end
