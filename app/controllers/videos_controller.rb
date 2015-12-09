class VideosController < ApplicationController
  before_action :set_capture
  before_action :set_video, only: %w(destroy open upload_youtube)

  def index
    @videos = search_videos
  end

  def search
    @videos = search_videos
  end

  def destroy
    @video.destroy
    head :ok
  end

  def open
    CommandUtil.open_paths(@video.output_file_path)
    head :ok
  end

  def upload_youtube
    UploadVideoWorker.perform_async(@video.id)
    redirect_to action: :index
  end

  def extract
    ExtractVideoFilesWorker.perform_async(@capture.id)
    head :ok
  end

  private

  def search_videos
    videos = Video
    videos = videos.where(capture_id: @capture.id) if @capture
    videos.order(started_at: :desc)
  end

  def set_video
    @video = Video.find(params[:id])
  end

  def set_capture
    @capture = params[:capture_id] ? Capture.find_by_id(params[:capture_id]) : nil
  end
end
