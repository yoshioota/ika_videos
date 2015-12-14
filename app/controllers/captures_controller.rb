class CapturesController < ApplicationController
  before_action :set_capture, only: [
      :show, :destroy, :execute_all,
      :calculate_total_frames, :open_capture, :open_videos]

  def index
    search_captures
  end

  def captures
    search_captures
  end

  def execute_all
    ExecuteAllWorker.perform_async(@capture.id)
    head :ok
  end

  def calculate_total_frames
    CalculateTotalFramesWorker.perform_async(@capture.id)
    head :ok
  end

  def bulk_destroy
    fail if params[:ids].blank?
    Capture.where(id: params[:ids]).update_all(visible: false, updated_at: Time.now)
    params[:ids].each do |capture_id|
      DeleteCaptureAndCachesWorker.perform_async(capture_id)
    end
    head :ok
  end

  def open_capture
    CommandUtil.open_paths(@capture.full_path)
    head :ok
  end

  def open_videos
    paths = @capture.videos.map(&:output_file_path).select{|path| File.file?(path)}
    CommandUtil.open_paths(*paths)
    head :ok
  end

  private

  def search_captures
    @captures = Capture
                  .visible
                  .order('started_at IS NULL')
                  .order(started_at: :desc)
                  .includes(:videos).all
  end

  def set_capture
    @capture = Capture.find(params[:id])
  end
end
