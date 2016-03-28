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
      last_pick = League.find(undo_params).picks.where.not(player_id: nil, keeper: true).last
      last_pick_player = last_pick.player
      last_pick.player_id = nil
      if last_pick.save
        if last_pick.last_pick_of_draft?
          last_pick.league.begin_draft
        end
        render json: last_pick.league.draft_state.merge(
          is_undo: true,
          last_selected_player: last_pick_player
        ).camelize
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
