class OpenCvUtil

  # Elgato の extended を設定するとカラーレンジが狭まるのでそれ用のファイルも追加
  BLACK_IMAGE_PATH  = Rails.root.join("data/#{Settings.default_scale}-black.jpeg").to_s
  WHITE_IMAGE_PATH  = Rails.root.join("data/#{Settings.default_scale}-white.jpeg").to_s
  FINISH_IMAGE_PATH = Rails.root.join("data/#{Settings.default_scale}-finish.jpeg").to_s

  BLACK_IMAGE = OpenCV::IplImage.load(BLACK_IMAGE_PATH, OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
  WHITE_IMAGE = OpenCV::IplImage.load(WHITE_IMAGE_PATH, OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
  FINISH_IMAGE = OpenCV::IplImage.load(FINISH_IMAGE_PATH, OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
                     .threshold(0, 255, OpenCV::CV_THRESH_BINARY | OpenCV::CV_THRESH_OTSU)[0]

  BLACK_WHITE_THRESHOLD = 10_000_000
  FINISH_THRESHOLD      = 50_000_000

  def initialize(file_path)
    @gs_frame_image = OpenCV::IplImage.load(file_path, OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
    @bw_frame_image = @gs_frame_image.threshold(0, 255, OpenCV::CV_THRESH_BINARY | OpenCV::CV_THRESH_OTSU)[0]
  end

  def black?
    bw_check(BLACK_IMAGE)
  end

  def white?
    bw_check(WHITE_IMAGE)
  end

  # MEMO: Finish画面の誤差が大きすぎるので別実装
  def finish?
    result = @bw_frame_image.match_template(FINISH_IMAGE, OpenCV::CV_TM_SQDIFF)
    hash = min_max_loc_to_hash(result.min_max_loc)
    hash[:min_score] <= FINISH_THRESHOLD && hash[:max_score] <= FINISH_THRESHOLD ? hash : nil
  end

  private

  def bw_check(template)
    result = @gs_frame_image.match_template(template, OpenCV::CV_TM_SQDIFF)
    hash = min_max_loc_to_hash(result.min_max_loc)
    hash[:min_score] <= BLACK_WHITE_THRESHOLD && hash[:max_score] <= BLACK_WHITE_THRESHOLD ? hash : nil
  end

  # MEMO: グレースケール化 -> 2値化
  # http://ser1zw.hatenablog.com/entry/20110321/1300640121
  def load_black_white(path)
    OpenCV::IplImage
        .load(path, OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
        .threshold(0, 255, OpenCV::CV_THRESH_BINARY | OpenCV::CV_THRESH_OTSU)[0]
  end

  def min_max_loc_to_hash(min_max_loc)
    Hash[%i{min_score max_score min_point max_point}.zip(min_max_loc)]
  end
end
