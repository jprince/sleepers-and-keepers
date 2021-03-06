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
    @league = league
    @teams = @league.teams.sort_by(&:name)
  end

  def new
    @league = league
    @team = @league.teams.build
  end

  def show
    @league = league
    @team = @league.teams.find(params[:id])
    @players = @team.players.order('picks.overall_pick')
    @owner = User.find(@team[:user_id])
  end

  private

  def league
    League.find(params[:league_id])
  end

  def team_params
    params.require(:team)
          .permit(:name, :short_name)
          .merge(draft_pick: league.size - league.teams.length)
          .merge(user_id: current_user.id)
  end
end
