class GameResultsController < ApplicationController

  def index
    @span_type = params[:span_type].presence || 'daily'
    @result_type = params[:result_type].presence || 'rule_stage'

    @game_results = GameResult.order(win_loss_rate: :desc).all

    @game_results = @game_results.where(span_type: @span_type)
    @game_results = @game_results.where(result_type: @result_type)
    case @span_type
    when 'daily'
      @game_results = @game_results.where(date_on: Date.today)
    when 'weekly'
      @game_results = @game_results.where(date_on:Date.today.beginning_of_week(:sunday))
    end
  end
end
