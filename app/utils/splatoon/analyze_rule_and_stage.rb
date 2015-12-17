class Splatoon::AnalyzeRuleAndStage
  include OpenCV

  NEW_SIZE = CvSize.new(1280 / Settings.default_scale, 720 / Settings.default_scale)

  STAGE_THRESHOLD       = 50_000_000

  cattr_accessor :rule_templates
  cattr_accessor :stage_templates

  def initialize(file_path)
    fail file_path.to_s unless File.file?(file_path)
    @tgt_gray_image = IplImage.load(file_path, CV_LOAD_IMAGE_GRAYSCALE).resize(NEW_SIZE)
    @tgt_otsu_image = OpenCvUtil.to_otsu(@tgt_gray_image)
  end

  def rule
    rule_scores = {}

    @tgt_otsu_image.set_roi(rule_roi)

    get_rule_templates.each do |rule_name, rule_template|
      hash = min_max_loc_to_hash(@tgt_otsu_image.match_template(rule_template, CV_TM_SQDIFF).min_max_loc)
      hash[:rule_name] = rule_name
      rule_scores[hash[:min_score]] = hash
    end

    @tgt_otsu_image.reset_roi

    rule_scores.delete_if{ |min_score, _| min_score >= STAGE_THRESHOLD }

    rule_scores.values.sort_by{|h| h[:min_score]}.try(:first)
  end

  def stage
    stage_score_hash = {}

    @tgt_otsu_image.set_roi(stage_roi)

    get_stage_templates.each do |stage_name, stage_bw|
      hash = min_max_loc_to_hash(@tgt_otsu_image.match_template(stage_bw, CV_TM_SQDIFF).min_max_loc)
      hash[:stage_name] = stage_name
      stage_score_hash[hash[:min_score]] = hash
    end

    @tgt_otsu_image.reset_roi

    stage_score_hash.delete_if{ |min_score, _| min_score >= STAGE_THRESHOLD }

    stage_score_hash.values.sort_by{|h| h[:min_score]}.try(:first)
  end

  private

  def rule_roi
    CvRect.new(120, 62, 80, 17)
  end

  def stage_roi
    CvRect.new(180, 147, 130, 15)
  end

  def get_rule_templates
    return @@rule_templates if @@rule_templates

    @@rule_templates = {}
    Splatoon::RULES.keys.each do |rule_name|
      fail unless File.file?(path = Rails.root.join("data/rules/#{rule_name}.jpeg").to_s)
      @@rule_templates[rule_name] =
          IplImage.load(path, CV_LOAD_IMAGE_GRAYSCALE).threshold(240, 255, CV_THRESH_BINARY).resize(NEW_SIZE).set_roi(rule_roi)

      # @@rule_templates[rule_name].rectangle! rule_roi.top_left, rule_roi.bottom_right, color: OpenCV::CvColor::White
      # OpencvUtil.create_window(@@rule_templates[rule_name], rule_name.to_s)
    end

    # OpencvUtil.window_loop

    @@rule_templates
  end

  def get_stage_templates
    return @@stage_templates if @@stage_templates

    @@stage_templates = {}
    Splatoon::STAGES.keys.each do |stage_name|
      fail unless File.file?(path = Rails.root.join("data/stages/#{stage_name}.jpeg").to_s)
      @@stage_templates[stage_name] =
          IplImage.load(path, CV_LOAD_IMAGE_GRAYSCALE).threshold(240, 255, CV_THRESH_BINARY).resize(NEW_SIZE).set_roi(stage_roi)
    end
    @@stage_templates
  end

  def min_max_loc_to_hash(min_max_loc)
    Hash[%i{min_score max_score min_point max_point}.zip(min_max_loc)]
  end
end
