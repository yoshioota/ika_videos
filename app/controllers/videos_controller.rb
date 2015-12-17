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
    head :ok
  end

  def extract
    ExtractVideoFilesWorker.perform_async(@capture.id)
    head :ok
  end

  private

  def search_videos
    videos = Video
    videos = videos.where(capture_id: @capture.id) if @capture
    videos = videos.where(game_rule: params[:game_rule]) if params[:game_rule].present?
    videos = videos.where(game_stage: params[:game_stage]) if params[:game_stage].present?
    videos = videos.where(game_result: params[:game_result]) if params[:game_result].present?
    videos.order(started_at: :desc)
  end

  def set_video
    @video = Video.find(params[:id])
  end

  def set_capture
    @capture = params[:capture_id] ? Capture.find_by_id(params[:capture_id]) : nil
  end
end
