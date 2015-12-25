class GameResult < ActiveRecord::Base
  extend Enumerize

  scope :gachi, -> { where(rule: %w(area hoko yagura)) }

  enumerize :result_type, in: %i(rule_stage rule stage), scope: true
  enumerize :span_type, in: %i(total weekly daily), scope: true

  enumerize :stage, in: Splatoon::STAGES.keys
  enumerize :rule, in: Splatoon::RULES.keys
end
