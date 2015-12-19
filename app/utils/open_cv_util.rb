class OpenCvUtil
  include OpenCV

  def self.to_otsu(image)
    image.threshold(0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU)[0]
  end

  def self.create_window(image, name = Time.now.to_f.to_s)
    window = GUI::Window.new(name, CV_WINDOW_AUTOSIZE)
    window.show image
  end

  def self.window_loop
    GUI::wait_key
    GUI::Window.destroy_all
  end

  def self.min_max_loc_to_hash(min_max_loc)
    Hash[%i{min_score max_score min_point max_point}.zip(min_max_loc)]
  end
end
