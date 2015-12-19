class Splatoon::AnalyzeRuleAndStage
  include OpenCV

  NEW_SIZE = CvSize.new(1280, 720)

  STAGE_THRESHOLD       = 50_000_000

  cattr_accessor :rule_templates
  cattr_accessor :stage_templates

  def initialize(image)
    @tgt_gray_image = image.resize(NEW_SIZE)
    @tgt_bw_image = @tgt_gray_image.threshold(240, 255, CV_THRESH_BINARY)
  end

  def rule
    rule_scores = {}

    @tgt_bw_image.set_roi(rule_roi)

    get_rule_templates.each do |rule_name, rule_template|
      hash = OpenCvUtil.min_max_loc_to_hash(@tgt_bw_image.match_template(rule_template, CV_TM_SQDIFF).min_max_loc)
      hash[:rule_name] = rule_name
      rule_scores[hash[:min_score]] = hash
    end

    @tgt_bw_image.reset_roi

    rule_scores.delete_if{ |min_score, _| min_score >= STAGE_THRESHOLD }

    rule_scores.values.sort_by{|h| h[:min_score]}.try(:first)
  end

  def stage
    stage_score_hash = {}

    @tgt_bw_image.set_roi(target_stage_roi)
    # @tgt_bw_image.rectangle! target_stage_roi.top_left, target_stage_roi.bottom_right, color: OpenCV::CvColor::White
    # OpenCvUtil.create_window(@tgt_bw_image)
    # OpenCvUtil.window_loop

    get_stage_templates.each do |stage_name, stage_bw|
      hash = OpenCvUtil.min_max_loc_to_hash(@tgt_bw_image.match_template(stage_bw, CV_TM_SQDIFF).min_max_loc)
      hash[:stage_name] = stage_name
      stage_score_hash[hash[:min_score]] = hash
    end

    # OpenCvUtil.window_loop

    @tgt_bw_image.reset_roi

    # stage_score_hash.delete_if{ |min_score, _| min_score >= STAGE_THRESHOLD }
    # return nil if stage_score_hash.count.zero?
    stage_score_hash[stage_score_hash.keys.sort.first]
  end

  private

  def rule_roi
    CvRect.new(480, 248, 320, 68)
  end

  def target_stage_roi
    CvRect.new(746, 583, 492, 62)
  end

  def stage_roi
    CvRect.new(750, 585, 490, 60)
  end

  def get_rule_templates
    return @@rule_templates if @@rule_templates

    @@rule_templates = {}
    Splatoon::RULES.keys.each do |rule_name|
      fail unless File.file?(path = Rails.root.join("data/rules/#{rule_name}.jpeg").to_s)
      @@rule_templates[rule_name] = IplImage.load(path, CV_LOAD_IMAGE_GRAYSCALE).threshold(240, 255, CV_THRESH_BINARY).resize(NEW_SIZE)
      @@rule_templates[rule_name].set_roi(rule_roi)
      # @@rule_templates[rule_name].rectangle! rule_roi.top_left, rule_roi.bottom_right, color: OpenCV::CvColor::White
      # OpenCvUtil.create_window(@@rule_templates[rule_name], rule_name.to_s)
    end

    # OpenCvUtil.window_loop

    @@rule_templates
  end

  def get_stage_templates
    return @@stage_templates if @@stage_templates

    @@stage_templates = {}
    Splatoon::STAGES.keys.each do |stage_name|
      fail unless File.file?(path = Rails.root.join("data/stages/#{stage_name}.jpeg").to_s)
      @@stage_templates[stage_name] = IplImage.load(path, CV_LOAD_IMAGE_GRAYSCALE).threshold(240, 255, CV_THRESH_BINARY).resize(NEW_SIZE)
      @@stage_templates[stage_name].set_roi(stage_roi)
      # @@stage_templates[stage_name].rectangle! stage_roi.top_left, stage_roi.bottom_right, color: OpenCV::CvColor::White
      OpenCvUtil.create_window(@@stage_templates[stage_name], stage_name.to_s)
    end

    # OpenCvUtil.window_loop

    @@stage_templates
  end
end
