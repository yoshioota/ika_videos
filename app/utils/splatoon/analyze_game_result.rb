class Splatoon::AnalyzeGameResult
  include OpenCV

  NEW_SIZE = CvSize.new(1280 / Settings.default_scale, 720 / Settings.default_scale)

  GAME_RESULT_THRESHOLD = 50_000_000

  cattr_accessor :game_result_templates

  def initialize(file_path)
    fail file_path.to_s unless File.file?(file_path)
    @tgt_gray_image = IplImage.load(file_path, CV_LOAD_IMAGE_GRAYSCALE).resize(NEW_SIZE)
    @tgt_otsu_image = OpenCvUtil.to_otsu(@tgt_gray_image)
  end

  def game_result
    game_results_hash = {}

    get_game_result_templates.each do |game_result_name, game_result_template|
      hash = min_max_loc_to_hash(@tgt_otsu_image.match_template(game_result_template, CV_TM_SQDIFF).min_max_loc)
      hash[:game_result] = game_result_name
      game_results_hash[hash[:min_score]] = hash
    end

    game_results_hash.delete_if{ |min_score, _| min_score >= GAME_RESULT_THRESHOLD }

    game_results_hash.values.sort_by{|h| h[:min_score]}.try(:first)
  end

  private

  def game_result_roi
    CvRect.new(12, 8, 60, 30)
  end

  def get_game_result_templates
    return @@game_result_templates if @@game_result_templates

    @@game_result_templates = {}
    %i(win lose).each do |game_result_name|
      fail unless File.file?(path = Rails.root.join("data/game_results/#{game_result_name}.jpeg").to_s)
      @@game_result_templates[game_result_name] = IplImage.load(path, CV_LOAD_IMAGE_GRAYSCALE).threshold(245, 255, CV_THRESH_BINARY).resize(NEW_SIZE)
      # @@game_result_templates[game_result_name].rectangle! game_result_roi.top_left, game_result_roi.bottom_right, color: CvColor::White
      @@game_result_templates[game_result_name].set_roi(game_result_roi)
      # OpencvUtil.create_window @@game_result_templates[game_result_name]
    end

    @@game_result_templates
  end

  def min_max_loc_to_hash(min_max_loc)
    Hash[%i{min_score max_score min_point max_point}.zip(min_max_loc)]
  end
end
