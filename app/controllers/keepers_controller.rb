class KeepersController < ApplicationController
  def create
    keeper_pick = Pick.find(create_params[:pick_id])
    keeper_pick.player_id = create_params[:player_id]
    keeper_pick.keeper = true

    if keeper_pick.save
      flash.alert = 'Saved successfully'
      render_edit
    else
      flash.alert = 'Unable to save keeper'
    end
  end

  def destroy
    keeper_pick = Pick.find(destroy_params)
    keeper_pick.player_id = nil
    keeper_pick.keeper = false
    if keeper_pick.save
      flash.alert = 'Removed successfully'
      render_edit
    else
      flash.alert = 'Unable to remove keeper'
    end
  end

  def edit
    render_edit
  end

  private

  def create_params
    params.permit(:pick_id, :player_id)
  end

  def destroy_params
    params.require(:pick_id)
  end

  def league_id
    params.require(:league_id)
  end

  def render_edit
    @league = League.find(league_id)
    sport = Sport.find(@league.sport.id)
    @available_picks = @league.picks.where(player_id: nil).sort_by(&:overall_pick)
    @keeper_picks = @league.picks.where(keeper: true).sort_by(&:overall_pick)
    kept_player_ids = @keeper_picks.map(&:player_id)
    @available_players = sport.players.where.not(id: kept_player_ids)
    @positions = sport.position_options
    @teams = @league.teams.sort_by(&:draft_pick)
  end
end
