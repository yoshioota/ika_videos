# == Schema Information
#
# Table name: game_results
#
#  id            :integer          not null, primary key
#  result_type   :string(255)
#  span_type     :string(255)
#  date_on       :string(255)
#  rule          :string(255)
#  stage         :string(255)
#  wins          :integer
#  losses        :integer
#  win_loss_rate :float(24)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class GameResult < ActiveRecord::Base
  extend Enumerize

  scope :gachi, -> { where(rule: %w(area hoko yagura)) }

  enumerize :result_type, in: %i(rule_stage rule stage), scope: true
  enumerize :span_type, in: %i(total weekly daily), scope: true

  enumerize :stage, in: Splatoon::STAGES.keys
  enumerize :rule, in: Splatoon::RULES.keys
end
