class UploadVideoWorker
  include Sidekiq::Worker
  sidekiq_options unique: :until_executing
  sidekiq_options queue: :upload_youtube

  def perform(video_id)
    return unless video = Video.find_by_id(video_id)
    Youtube::Video.new.insert_by_video(video)
  end
end
