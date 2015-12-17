class Splatoon::AnalyzeKillDeath
  include OpenCV

  NEW_SIZE = CvSize.new(1280, 720)

  NUMBER_THRESHOLD = 10_000_000
  KILL_DEATH_SCENE_THRESHOLD = 1_000_000

  cattr_accessor :x_mark_template
  cattr_accessor :num_template

  def initialize(file_path)
    fail file_path.to_s unless File.file?(file_path)
    @tgt_gray_image = IplImage.load(file_path, CV_LOAD_IMAGE_GRAYSCALE)
    @tgt_bw_image = @tgt_gray_image.threshold(200, 255, CV_THRESH_BINARY)
  end

  def kill_death
    return nil unless kill_death_scene?
    compute_kill_death
  end

  def compute_kill_death
    ret = []
    pos = [1184, 100]
    2.times do |i|
      4.times do |j|
        kd = []
        2.times do |k|
          digits = [0,0]
          2.times do |l|
            delta_x = 17 * l
            delta_y = 330 * i + 65 * j + 21 * k
            roi = CvRect.new(pos[0] + delta_x, pos[1] + delta_y, 18, 18)
            # @tgt_bw_image.rectangle! roi.top_left, roi.bottom_right, color: CvColor::White
            @tgt_bw_image.set_roi roi
            num_results = Hash[(0..10).map do |num|
              [@tgt_bw_image.match_template(num_image(num), CV_TM_SQDIFF).min_max_loc[0], num == 10 ? 0 : num]
            end]
            digits[l] = num_results[num_results.keys.sort.first]
          end
          kd << digits[0] * 10 + digits[1]
        end
        ret << kd
      end
    end
    ret
  end

  def number
    pos = [615, 106]
    2.times do |area|
      4.times do |member|
        delta_y = (330 * area) + (65 * member)
        roi = CvRect.new(pos[0], pos[1] + delta_y, 41, 21)
        @tgt_bw_image.set_roi roi
        min_score = @tgt_bw_image.match_template(rank_mark, CV_TM_SQDIFF).min_max_loc[0]
        return (4 * area) + member if min_score <= NUMBER_THRESHOLD
      end
    end
    nil
  end

  def kill_death_scene?
    pos = [1175, 105]
    2.times do |area|
      4.times do |member|
        2.times do |kd|
          delta_y = 330 * area + 65 * member + 21 * kd
          roi = CvRect.new(pos[0], pos[1] + delta_y, 13, 13)
          @tgt_bw_image.set_roi roi
          min_score = @tgt_bw_image.match_template(x_mark, CV_TM_SQDIFF).min_max_loc[0]
          return false if min_score >= KILL_DEATH_SCENE_THRESHOLD
        end
      end
    end
    @tgt_bw_image.reset_roi
    true
  end

  def x_mark
    @@x_mark_template ||= IplImage
                       .load(Rails.root.join('data/kill-death.jpeg').to_s, CV_LOAD_IMAGE_GRAYSCALE)
                       .threshold(200, 255, CV_THRESH_BINARY)
    @@x_mark_template.set_roi(CvRect.new(1175, 105, 12, 12))
  end

  def num_image(num)
    roi = CvRect.new(0 + num * 16, 0, 16, 16)
    @@num_template ||= IplImage.load(Rails.root.join('data/nums.jpg').to_s, CV_LOAD_IMAGE_GRAYSCALE)
    @@num_template.set_roi(roi)
  end

  def rank_mark
    x_mark.set_roi(CvRect.new(615, 107, 40, 20))
  end
end
