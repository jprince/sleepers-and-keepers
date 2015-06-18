class KeepersController < ApplicationController
  def create
    keeper_pick = Pick.find(create_params[:pick_id])
    keeper_pick.player_id = create_params[:player_id]
    keeper_pick.keeper = true

    if keeper_pick.save
      flash.alert = 'Saved successfully'
      redirect_to edit_league_keepers_path(league_id)
    else
      flash.alert = 'Unable to save keeper'
    end
  end

  def edit
    @league = League.find(league_id)
    sport = Sport.find(@league.sport.id)
    @available_picks = @league.picks.where(player_id: nil)
    @keepers = @league.picks.where(keeper: true).map(&:player)
    kept_player_ids = @keepers.map(&:id)
    @available_players = sport.players.where.not(id: kept_player_ids)
    @positions = sport.positions
    @teams = @league.teams
  end

  private

  def create_params
    params.permit(:pick_id, :player_id)
  end

  def league_id
    params.require(:league_id)
  end
end
