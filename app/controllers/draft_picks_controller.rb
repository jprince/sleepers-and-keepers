class DraftPicksController < ApplicationController
  def create
    pick = Pick.find(create_params[:pick_id])
    league = pick.league
    pick.player_id = create_params[:player_id]
    if pick.save
      if league.picks.where(player_id: nil).count == 0
        league.complete_draft
      end
      render json: league.draft_state.try(:camelize)
    else
      flash.alert = 'Unable to save pick'
    end
  end

  def edit
    @league = League.find(edit_params)
    @available_picks = @league.picks.where(player_id: nil)
    @teams = @league.teams.sort_by(&:draft_pick)
  end

  def update
    if trade_params.to_h.any?
      Pick.execute_trade(trade_params)
      redirect_to action: :edit, status: 303
    else
      league = League.find(undo_params)
      last_pick = league.picks.where.not(keeper: true, player_id: nil).last
      last_pick_player = last_pick.player
      last_pick.player_id = nil
      if last_pick.save
        if last_pick.last_pick_of_draft?
          league.begin_draft
        end
        draft_state = league.draft_state.merge(
          is_undo: true,
          last_selected_player: {
            id: last_pick_player.id,
            first_name: last_pick_player.first_name,
            last_name: last_pick_player.last_name,
            position: last_pick_player.position,
            team: last_pick_player.team,
            injury: last_pick_player.injury,
            headline: last_pick_player.headline
          }
        ).camelize
        render json: draft_state
      else
        flash.alert = 'Unable to undo pick'
      end
    end
  end

  private

  def create_params
    params.require(:pick).permit(:pick_id, :player_id)
  end

  def edit_params
    params.require(:league_id)
  end

  def trade_params
    params.permit(picks: [team_one_picks: [], team_two_picks: []])
  end

  def undo_params
    params.require(:league_id)
  end
end
