class ExecuteAllWorker
  include Sidekiq::Worker
  sidekiq_options unique: :while_executing
  sidekiq_options queue: :execute_all

  def perform(capture_id)
    return unless Capture.find_by_id(capture_id)
    CalculateTotalFramesWorker.new.perform(capture_id)
    CreateFrameFilesWorker.new.perform(capture_id)
    CreateMarkersWorker.perform_async(capture_id)
  end
end
