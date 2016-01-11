# == Schema Information
#
# Table name: videos
#
#  id           :integer          not null, primary key
#  capture_id   :integer
#  total_frames :integer
#  start_frame  :integer
#  end_frame    :integer
#  youtube_id   :string(255)
#  started_at   :datetime
#  ended_at     :datetime
#  file_name    :string(255)
#  game_rule    :string(255)
#  game_stage   :string(255)
#  game_result  :string(255)
#  kills        :integer
#  deaths       :integer
#  rank_str     :string(255)
#  rank_no      :integer
#  rank_points  :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Video < ActiveRecord::Base
  extend Enumerize

  belongs_to :capture, counter_cache: true
  has_many :playlists_videos, dependent: :destroy

  enumerize :game_rule, in: Splatoon::RULES.keys
  enumerize :game_stage, in: Splatoon::STAGES.keys
  enumerize :game_result, in: Splatoon::RESULTS.keys

  scope :gachi, -> { where(game_rule: %w(area hoko yagura)) }
  scope :game_result_is_not_null, -> { where.not(game_result: nil) }

  def self.win_ratio(videos)
    game_results = videos.map(&:game_result)
    wins = game_results.count { |gr| gr == 'win' }
    loses = game_results.count { |gr| gr == 'lose' }
    if wins == 0
      0
    elsif loses == 0
      100
    else
      wins.to_f / (wins + loses) * 100
    end
  end

  def kill_ratio
    return nil if kills.blank? || deaths.blank?
    return -999 if kills.zero?
    return 999 if deaths.zero?
    ('%.1f' % (kills.to_f / deaths.to_f)).to_f
  end

  def output_file_path
    File.join Settings.movie_output_path, file_name
  end

  def total_seconds
    seconds, mod = total_frames.divmod(60)
    mod.zero? ? seconds : seconds + 1
  end

  # TODO: upload_statusを作りアップロード中かの判別をする。
  def uploadable?
    exist_local? && !youtube_id?
  end

  def exist_local?
    File.exist?(output_file_path)
  end

  def title
    [File.basename(output_file_path, '.*'), game_rule, game_stage, game_result].join('-')
  end
end
