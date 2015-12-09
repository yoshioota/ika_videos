class Marker < ActiveRecord::Base
  belongs_to :capture, counter_cache: true

  def file_path
    "/Users/yoshioota/tmp/test/#{min}/img-#{'%015d' % original_frame}.jpeg"
  end

  def file_name
    File.basename(file_path)
  end

  def self.get_frame_image_path(min, sec, frame)
    original_frame = (sec * 60) + frame + 1
    "/Users/yoshioota/tmp/test/#{min}/img-#{'%015d' % original_frame}.jpeg"
  end
end
