class UpdateGameResultWorker
  include Sidekiq::Worker
  sidekiq_options queue: :update_game_result

  def perform
    summarize_total
    summarize_daily(Date.today)
    summarize_daily(Date.yesterday)
  end

  def summarize_total
    Splatoon::RULES.each do |rule, _|
      Splatoon::STAGES.each do |stage, _|
        gr = GameResult.find_or_create_by(result_type: 'rule_stage', rule: rule, stage: stage)
        videos = Video.where(game_rule: rule, game_stage: stage).to_a
        gr.wins = videos.count { |v| v.game_result.win? }
        gr.losses = videos.count { |v| v.game_result.lose? }
        gr.win_loss_rate = win_loss_rate(gr.wins, gr.losses)
        gr.save!
      end
    end

    Splatoon::RULES.each do |rule, _|
      gr = GameResult.find_or_create_by(result_type: 'rule', rule: rule)
      videos = Video.where(game_rule: rule).to_a
      gr.wins = videos.count { |v| v.game_result.win? }
      gr.losses = videos.count { |v| v.game_result.lose? }
      gr.win_loss_rate = win_loss_rate(gr.wins, gr.losses)
      gr.save!
    end

    Splatoon::STAGES.each do |stage, _|
      gr = GameResult.find_or_create_by(result_type: 'stage', stage: stage)
      videos = Video.where(game_stage: stage).to_a
      gr.wins = videos.count { |v| v.game_result.win? }
      gr.losses = videos.count { |v| v.game_result.lose? }
      gr.win_loss_rate = win_loss_rate(gr.wins, gr.losses)
      gr.save!
    end
  end

  def summarize_daily(date_on)
    Splatoon::RULES.each do |rule, _|
      Splatoon::STAGES.each do |stage, _|
        gr = GameResult.find_or_create_by(span_type: 'daily', result_type: 'rule_stage', rule: rule, stage: stage, date_on: date_on)
        videos = Video.where(started_at: date_on.to_time.all_day, game_rule: rule, game_stage: stage).to_a
        gr.wins = videos.count { |v| v.game_result.win? }
        gr.losses = videos.count { |v| v.game_result.lose? }
        gr.win_loss_rate = win_loss_rate(gr.wins, gr.losses)
        gr.save!
      end
    end

    Splatoon::RULES.each do |rule, _|
      gr = GameResult.find_or_create_by(span_type: 'daily', result_type: 'rule', rule: rule, date_on: date_on)
      videos = Video.where(started_at: date_on.to_time.all_day, game_rule: rule).to_a
      gr.wins = videos.count { |v| v.game_result.win? }
      gr.losses = videos.count { |v| v.game_result.lose? }
      gr.win_loss_rate = win_loss_rate(gr.wins, gr.losses)
      gr.save!
    end

    Splatoon::STAGES.each do |stage, _|
      gr = GameResult.find_or_create_by(span_type: 'daily', result_type: 'stage', stage: stage, date_on: date_on)
      videos = Video.where(started_at: date_on.to_time.all_day, game_stage: stage).to_a
      gr.wins = videos.count { |v| v.game_result.win? }
      gr.losses = videos.count { |v| v.game_result.lose? }
      gr.win_loss_rate = win_loss_rate(gr.wins, gr.losses)
      gr.save!
    end
  end

  def win_loss_rate(wins, losses)
    if wins.nonzero? && losses.nonzero?
      wins.to_f / (wins + losses) * 100
    elsif wins.zero?
      0
    elsif losses.zero?
      100
    end.round(2)
  end
end
