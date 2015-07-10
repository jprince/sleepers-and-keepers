class DraftOrderController < ApplicationController
  def edit
    @league = League.find(edit_params)
    @teams = @league.teams.sort_by(&:draft_pick)
    @league_full = @league.teams.length == @league.size
  end

  def update
    Team.bulk_update(update_params)
    redirect_to league_draft_order_path
  end

  private

  def edit_params
    params.require(:league_id)
  end

  def update_params
    params.permit(teams: [:draft_pick]).require(:teams)
  end
end
