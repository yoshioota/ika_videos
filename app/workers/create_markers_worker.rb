class CreateMarkersWorker
  include Sidekiq::Worker
  sidekiq_options unique: :while_executing
  sidekiq_options queue: :create_markers

  def perform(capture_id)
    return unless @capture = Capture.find_by_id(capture_id)

    @analyze_frames = Capture::AnalyzeFrames.new(capture: @capture, verbose: true)
    @capture.start_end(:create_markers) { create_markers_total_frames! }
    CreateVideosWorker.perform_async(capture_id)
  end

  def create_markers_total_frames!
    # フレーム数が大量になる可能性があるので一定数づつ渡す。
    (0...@capture.total_frames).step(6).to_enum.each_slice(batch_size).with_index do |total_frame_array, idx|
      create_marker_frame(total_frame_array)
      gc_check(idx)
    end
    gc_check(nil, true)
  end

  def create_marker_frame(total_frame_array)
    calc = ->(total_frame) do
      @analyze_frames.analyze_by_total_frame(total_frame)
    end

    if Settings.create_markers.use_parallel
      Parallel.map(total_frame_array, in_processes: Settings.create_markers.concurrency, &calc)
    else
      total_frame_array.each(&calc)
    end
  end

  # FIXME: TODO: GCのタイミングをメモリが圧迫したら行なうようにする。
  def gc_check(idx, force = false)
    unless force
      return unless (idx % Settings.create_markers.gc_timing).zero?
    end
    GC.start
  end

  def batch_size
    Settings.create_markers.concurrency * Settings.create_markers.batch_size
  end
end
