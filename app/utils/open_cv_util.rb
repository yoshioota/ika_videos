class OpenCvUtil

  # Elgato の extended を設定するとカラーレンジが狭まるのでそれ用のファイルも追加
  BLACK_IMAGE_PATH  = Rails.root.join("data/#{Settings.default_scale}-black.jpeg").to_s
  WHITE_IMAGE_PATH  = Rails.root.join("data/#{Settings.default_scale}-white.jpeg").to_s
  FINISH_IMAGE_PATH = Rails.root.join("data/#{Settings.default_scale}-finish.jpeg").to_s

  THRESHOLD = 10_000_000

  def black?(file_path)
    check(BLACK_IMAGE_PATH, file_path, OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
  end

  def white?(file_path)
    check(WHITE_IMAGE_PATH, file_path, OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
  end

  # MEMO: Finish画面の誤差が大きすぎるので別実装
  def finish?(file_path)
    score_threshold = 50_000_000

    template = load_black_white(FINISH_IMAGE_PATH)
    image = load_black_white(file_path)

    result = image.match_template(template, OpenCV::CV_TM_SQDIFF)
    hash = Hash[%w{min_score max_score min_point max_point}.zip(result.min_max_loc)].with_indifferent_access
    hash[:min_score] <= score_threshold && hash[:max_score] <= score_threshold ? hash : nil
  end

  def check(template_path, file_path, iscolor = OpenCV::CV_LOAD_IMAGE_COLOR, score_threshold = THRESHOLD)
    arr = min_max(template_path, file_path, iscolor)
    hash = Hash[%w{min_score max_score min_point max_point}.zip(arr)].with_indifferent_access
    hash[:min_score] <= score_threshold && hash[:max_score] <= score_threshold ? hash : nil
  end

  def min_max(template_path, file_path, iscolor = OpenCV::CV_LOAD_IMAGE_COLOR, method = OpenCV::CV_TM_SQDIFF)
    template = OpenCV::IplImage.load(template_path, iscolor)
    image = OpenCV::IplImage.load(file_path, iscolor)
    result = image.match_template(template, method)
    result.min_max_loc
  end

  # MEMO: グレースケール化 -> 2値化
  # http://ser1zw.hatenablog.com/entry/20110321/1300640121
  def load_black_white(path)
    OpenCV::IplImage
        .load(path, OpenCV::CV_LOAD_IMAGE_GRAYSCALE)
        .threshold(0, 255, OpenCV::CV_THRESH_BINARY | OpenCV::CV_THRESH_OTSU)[0]
  end
end
