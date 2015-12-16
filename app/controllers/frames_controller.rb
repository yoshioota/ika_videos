class FramesController < ApplicationController
  before_action :set_capture

  def index
    search_frames
  end

  def search
    search_frames
  end

  def img
    path = File.exist?(@capture.get_frame_image_file_path_total_frame(params[:id].to_i)) ?
        @capture.get_frame_image_file_path_total_frame(params[:id].to_i) :
        Rails.root.join('data/no-image.jpg').to_s # FIXME: assets/images/に入れようとしたけどうまくいかなかったので一旦dataへ入れる。
    send_file(path, disposition: 'inline')
  end

  def create_files
    CreateFrameFilesWorker.perform_async(@capture.id)
    head :ok
  end

  private

  def search_frames
    @min = (params[:min].presence || 0).to_i
    @sec = (params[:sec].presence || 0).to_i
    @step = (params[:step].presence || 60).to_i
    @limit = (params[:limit].presence || 100).to_i
    @frames = []

    base_frame = @min * 3600 + @sec * 60

    @limit.times do |idx|
      total_frame = base_frame + (@step * idx)
      next unless File.exist?(@capture.get_frame_image_file_path_total_frame(total_frame))
      hour, min, sec, frame = TimeUtil.total_frame_to_hmsf(total_frame)
      @frames << {
          hour: hour,
          min: min,
          sec: sec,
          frame: frame,
          total_frame: total_frame
      }
    end
  end

  def set_capture
    @capture = Capture.find(params[:capture_id])
  end
end
