class OpencvUtil
  include OpenCV

  def self.to_otsu(image)
    image.threshold(0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU)[0]
  end

  def self.create_window(image, name = Time.now.to_f.to_s)
    window = GUI::Window.new(name)
    window.show image
  end

  def self.window_loop
    GUI::wait_key
    GUI::Window.destroy_all
  end
end
