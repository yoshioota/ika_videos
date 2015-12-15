class CheckCaptureDirWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable
  # sidekiq_options unique: :until_executing
  sidekiq_options queue: :check_capture_dir

  recurrence { minutely }

  def perform
    check_file_existence
    check_new_files
  end

  def check_file_existence
    Capture.find_each do |capture|
      capture.update!(exist: File.exist?(capture.full_path))
    end
  end

  def check_new_files
    Dir[File.join(Settings.capture_path,'**/*.mp4')].each do |path|
      next if /Flashback Recording Buffer.noindex/ === path
      capture = create_capture(path)
      if capture.total_frames.nil?
        CalculateTotalFramesWorker.new.perform(capture.id)
        CreateFrameFilesWorker.new(capture.id).make_frames(start_frame: 0, end_frame: 1)
        ExecuteAllWorker.perform_async(capture.id)
      end
    end
  end

  def create_capture(full_path)
    capture = Capture.lock.find_or_create_by(full_path: full_path)
    capture.title = File.basename(full_path)
    metadata = FfmpegUtil.get_metadata(full_path)
    capture.duration = metadata[:duration]
    capture.ended_at = metadata[:creation_time] || Time.now
    capture.exist = true
    capture.save!
    capture
  end
end
