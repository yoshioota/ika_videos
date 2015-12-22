class GameResultsController < ApplicationController

  def index
    @game_results = GameResult.order(win_loss_rate: :desc).all
    @game_results = @game_results.where(result_type: params[:type].presence || 'rule_stage')
    @game_results = @game_results.where(date_on: Date.today)
  end
end
