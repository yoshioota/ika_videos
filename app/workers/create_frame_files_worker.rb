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
      FfmpegUtil.clean_frame_dir(min_dir)
      pattern = File.join(min_dir, 'img-%015d.jpeg')
      FfmpegUtil.make_frames(min * 60, @capture.full_path, pattern, 3600, scale)
    end
  end

  # TODO: 最終的に全体をCvCptureから取るようにする。
  include OpenCV
  def make_frame(total_frame, scale = Settings.default_scale)
    # debugger
    min = total_frame / 3600
    frame_no = total_frame % 3600 + 1

    output_file_dir = @capture.get_frames_dir(scale)

    min_dir = File.join(output_file_dir, min.to_s)
    FileUtils.mkdir_p(min_dir)

    cv_capture = CvCapture.open(@capture.full_path)
    cv_capture.frames= total_frame
    output_path = File.join(min_dir, "#{'img-%015d.jpeg' % frame_no}")
    image = cv_capture.query
    image.save_image(output_path)
  end

  def make_frames(start_frame:, end_frame:, scale: Settings.default_scale)
    start_min = start_frame / 3600
    end_min = end_frame / 3600
    output_file_path = @capture.get_frames_dir(scale)

    (start_min..end_min).each do |min|
      min_dir = File.join(output_file_path, min.to_s)
      FfmpegUtil.clean_frame_dir(min_dir)
      pattern = File.join(min_dir, 'img-%015d.jpeg')
      FfmpegUtil.make_frames(min * 60, @capture.full_path, pattern, end_frame - start_frame, scale)
    end
  end
end
