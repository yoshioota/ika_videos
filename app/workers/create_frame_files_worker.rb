class CreateFrameFilesWorker
  include Sidekiq::Worker
  sidekiq_options queue: :create_frame_files
  sidekiq_options unique: :while_executing

  def initialize(capture_id = nil)
    @capture = Capture.find(capture_id) if capture_id
  end

  def perform(capture_id)
    return unless @capture = Capture.find_by_id(capture_id)
    @capture.start_end(:create_thumbnails) do
      make_frames_all(scale: Settings.default_scale)
    end
  end

  def make_frames_all(scale:)
    output_file_path = @capture.get_frames_dir(scale)

    (0..@capture.total_min).each do |min|
      min_dir = File.join(output_file_path, min.to_s)
      FfmpegUtil.initialize_frame_dir(min_dir)
      pattern = File.join(min_dir, 'img-%015d.jpeg')
      FfmpegUtil.make_frames(min * 60, @capture.full_path, pattern, 3600, scale)
    end
  end

  def make_frames(start_frame:, end_frame:, scale: Settings.default_scale)
    start_min = start_frame / 3600
    end_min = end_frame / 3600
    output_file_path = @capture.get_frames_dir(scale)

    (start_min..end_min).each do |min|
      min_dir = File.join(output_file_path, min.to_s)
      FfmpegUtil.initialize_frame_dir(min_dir)
      pattern = File.join(min_dir, 'img-%015d.jpeg')
      FfmpegUtil.make_frames(min * 60, @capture.full_path, pattern, end_frame - start_frame, scale)
    end
  end
end
