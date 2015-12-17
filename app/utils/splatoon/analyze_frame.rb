class Splatoon::AnalyzeFrame
  include OpenCV

  BLACK_IMAGE_PATH  = Rails.root.join("data/7-black.jpeg").to_s
  WHITE_IMAGE_PATH  = Rails.root.join("data/7-white.jpeg").to_s
  FINISH_IMAGE_PATH = Rails.root.join("data/4-finish.jpeg").to_s

  NEW_SIZE = CvSize.new(1280 / Settings.default_scale, 720 / Settings.default_scale)

  BLACK_IMAGE  = IplImage.load(BLACK_IMAGE_PATH, CV_LOAD_IMAGE_GRAYSCALE).resize(NEW_SIZE)
  WHITE_IMAGE  = IplImage.load(WHITE_IMAGE_PATH, CV_LOAD_IMAGE_GRAYSCALE).resize(NEW_SIZE)
  FINISH_IMAGE = IplImage.load(FINISH_IMAGE_PATH, CV_LOAD_IMAGE_GRAYSCALE)
                     .threshold(0, 255, CV_THRESH_BINARY | CV_THRESH_OTSU)[0].resize(NEW_SIZE)

  BLACK_WHITE_THRESHOLD = 10_000_000
  FINISH_THRESHOLD      = 50_000_000

  def initialize(file_path)
    fail file_path.to_s unless File.file?(file_path)
    @tgt_gray_image = IplImage.load(file_path, CV_LOAD_IMAGE_GRAYSCALE).resize(NEW_SIZE)
    @tgt_otsu_image = OpenCvUtil.to_otsu(@tgt_gray_image)
  end

  def analyze
    ret = {black: nil, white: nil, finish: nil}
    return ret if ret[:black] = black?
    return ret if ret[:white] = white?
    return ret if ret[:finish] = finish?
    ret
  end

  def black?
    bw_check(BLACK_IMAGE)
  end

  def white?
    bw_check(WHITE_IMAGE)
  end

  # MEMO: Finish画面の誤差が大きすぎるので別実装
  def finish?
    result = FINISH_IMAGE.match_template(@tgt_otsu_image, CV_TM_SQDIFF)
    hash = min_max_loc_to_hash(result.min_max_loc)
    hash[:min_score] <= FINISH_THRESHOLD ? hash : nil
  end

  private

  def bw_check(template)
    result = @tgt_gray_image.match_template(template, CV_TM_SQDIFF)
    hash = min_max_loc_to_hash(result.min_max_loc)
    hash[:min_score] <= BLACK_WHITE_THRESHOLD ? hash : nil
  end

  def min_max_loc_to_hash(min_max_loc)
    Hash[%i{min_score max_score min_point max_point}.zip(min_max_loc)]
  end
end
