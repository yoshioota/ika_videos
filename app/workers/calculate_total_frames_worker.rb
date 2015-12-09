class CalculateTotalFramesWorker
  include Sidekiq::Worker
  sidekiq_options unique: :while_executing

  def perform(capture_id)
    return unless capture = Capture.find_by_id(capture_id)
    capture.start_end(:compute_total_frames) do
      capture.total_frames = FfmpegUtil.get_total_frames(capture.full_path)
      capture.started_at = capture.ended_at - (capture.total_frames / 60)
      capture.save!
    end
  end
end
