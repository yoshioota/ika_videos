# == Schema Information
#
# Table name: markers
#
#  id          :integer          not null, primary key
#  capture_id  :integer          not null
#  total_frame :integer          not null
#  marker_type :string(255)      not null
#  description :string(255)
#  min_score   :decimal(21, 1)   not null
#  max_score   :decimal(21, 1)   not null
#  min_point_x :integer
#  min_point_y :integer
#  max_point_x :integer
#  max_point_y :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

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
