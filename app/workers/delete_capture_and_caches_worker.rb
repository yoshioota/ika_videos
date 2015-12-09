class DeleteCaptureAndCachesWorker
  include Sidekiq::Worker
  sidekiq_options unique: :while_executing

  def perform(capture_id)
    return unless capture = Capture.find_by_id(capture_id)
    path = capture.get_frames_dir
    FileUtils.rm_rf(capture.captured_dir) if Settings.delete_capture_dir
    FileUtils.rm_rf(path)
    FileUtils.rm_f(capture.videos.map(&:output_file_path)) if Settings.delete_video_file
    capture.destroy!
  end
end
