class DraftPicksController < ApplicationController
  def edit
    @league = League.find(edit_params)
    @available_picks = @league.picks.where(player_id: nil)
    @teams = @league.teams.sort_by(&:draft_pick)
  end

  def update
    Pick.execute_trade(update_params)
    redirect_to action: :edit, status: 303
  end

  private

  def edit_params
    params.require(:league_id)
  end

  def update_params
    params.permit(picks: [team_one_picks: [], team_two_picks: []]).require(:picks)
  end
end
