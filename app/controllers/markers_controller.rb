class MarkersController < ApplicationController
  before_action :set_capture
  before_action :set_marker, only: %w(show analyze)

  def index
    @markers = @capture.markers.all
  end

  def destroy
    @marker.destroy
    redirect_to markers_url, notice: 'Marker was successfully destroyed.'
  end

  def create_markers
    CreateMarkersWorker.perform_async(@capture.id)
    head :ok
  end

  def create_games
    CreateVideosWorker.perform_async(@capture.id)
    head :ok
  end

  private

  def set_marker
    @marker = Marker.find(params[:id])
  end

  def set_capture
    @capture = Capture.find(params[:capture_id])
  end
end
