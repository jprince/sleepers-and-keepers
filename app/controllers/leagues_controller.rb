class LeaguesController < ApplicationController
  def create
    create_params = league_params
    create_params[:sport_id] = Sport.where(name: league_params[:sport]).first.id
    create_params.delete(:sport)
    create_params[:user_id] = current_user.id

    @league = League.new(create_params)
    if @league.save
      flash.alert = 'Created successfully'
      redirect_to league_path(@league.id)
    else
      flash.alert = 'Unable to save league'
    end
  end

  def new
    @league = League.new
  end

  def show
    @league = League.find(league_id)
  end

  private

  def league_id
    params.require(:id)
  end

  def league_params
    @league_params = params.require(:league).permit(:name, :password, :sport, :size, :rounds)
  end
end
