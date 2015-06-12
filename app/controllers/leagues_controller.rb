class LeaguesController < ApplicationController
  def create
    @league = League.new(league_params)
    if @league.save
      flash.alert = 'Created successfully'
      redirect_to league_path(@league.id)
    else
      flash.alert = 'Unable to save league'
    end
  end

  def index
    @leagues = League.all
  end

  def new
    @league = League.new
  end

  def show
    @league = League.find(league_id)
    @draft_status = DraftStatus.find(@league.draft_status_id).description
    @league_full = @league.teams.length == @league.size
    @owner_id = @league.user_id
    @user = current_user
  end

  private

  def league_id
    params.require(:id)
  end

  def league_params
    params.require(:league).permit(:name, :password, :size, :rounds)
      .merge(draft_status_id: DraftStatus.find_by(description: 'Not Started').id)
      .merge(sport_id: Sport.find_by(name: params[:league][:sport]).id)
      .merge(user_id: current_user.id)
  end
end
