class Splatoon::AnalyzeGameResult
  include OpenCV

  NEW_SIZE = CvSize.new(1280, 720)

  GAME_RESULT_THRESHOLD = 80_000_000

  cattr_accessor :game_result_templates

  def self.under_threshold?(score)
    score < GAME_RESULT_THRESHOLD
  end

  def initialize(image)
    @tgt_gray_image = image.resize(NEW_SIZE)
    @tgt_otsu_image = OpenCvUtil.to_otsu(@tgt_gray_image)
  end

  def game_result
    game_results_hash = {}

    @tgt_otsu_image.set_roi(target_game_result_roi)

    get_game_result_templates.each do |game_result_name, game_result_template|
      hash = min_max_loc_to_hash(@tgt_otsu_image.match_template(game_result_template, CV_TM_SQDIFF).min_max_loc)
      hash[:game_result] = game_result_name
      game_results_hash[hash[:min_score]] = hash
    end

    @tgt_otsu_image.reset_roi

    game_results_hash.values.sort_by{|h| h[:min_score]}.first
  end

  private

  def target_game_result_roi
    CvRect.new(47, 31, 242, 122)
  end

  def game_result_roi
    CvRect.new(48, 32, 240, 120)
  end

  def get_game_result_templates
    return @@game_result_templates if @@game_result_templates

    @@game_result_templates = {}
    %i(win lose).each do |game_result_name|
      fail unless File.file?(path = Rails.root.join("data/game_results/#{game_result_name}.jpeg").to_s)
      @@game_result_templates[game_result_name] = IplImage.load(path, CV_LOAD_IMAGE_GRAYSCALE).threshold(245, 255, CV_THRESH_BINARY).resize(NEW_SIZE)
      # @@game_result_templates[game_result_name].rectangle! game_result_roi.top_left, game_result_roi.bottom_right, color: CvColor::White
      @@game_result_templates[game_result_name].set_roi(game_result_roi)
      # OpenCvUtil.create_window @@game_result_templates[game_result_name]
    end

    # OpenCvUtil.window_loop

    @@game_result_templates
  end

  def min_max_loc_to_hash(min_max_loc)
    Hash[%i{min_score max_score min_point max_point}.zip(min_max_loc)]
  end
end
