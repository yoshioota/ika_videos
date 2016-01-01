class GameResultsController < ApplicationController

  def index
    search
  end

  private

  def search
    @span_type = params[:span_type].presence || 'daily'
    @result_type = params[:result_type].presence || 'rule_stage'
    set_from_to_on

    @game_results = GameResult.order(win_loss_rate: :desc).all
    @game_results = @game_results.where(span_type: @span_type)
    @game_results = @game_results.where(result_type: @result_type)
    @game_results = @game_results.where(date_on: @from_on)
  end

  def set_from_to_on
    @from_on, @to_on = case @span_type
                       when 'daily'
                         from = TimeUtil.param_date_to_date(params[:date_on]).presence || Date.today
                         [from, from]
                       when 'weekly' then
                         from = (TimeUtil.param_date_to_date(params[:date_on]).presence || Date.today).beginning_of_week(:sunday)
                         to = (TimeUtil.param_date_to_date(params[:date_on]).presence || Date.today).end_of_week(:sunday)
                         [from, to]
                       end
  end
end
