class TeamsController < ApplicationController
  def create
    @team = league.teams.build(team_params)
    if @team.save
      flash.alert = 'Created successfully'
      redirect_to league_team_path(league, @team)
    else
      flash.alert = 'Unable to save league'
    end
  end

  def index
    @teams = league.teams
  end

  def new
    @league = league
    @team = @league.teams.build
  end

  def show
    @team = league.teams.find_by_id(params[:id])
    @owner = User.find_by_id(@team[:user_id])
  end

  private

  def league
    League.find_by_id(params[:league_id])
  end

  def team_params
    params.require(:team)
      .permit(:name, :short_name)
      .merge(user_id: current_user.id)
  end
end
