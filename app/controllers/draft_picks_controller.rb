class DraftPicksController < ApplicationController
  def create
    pick = Pick.find(create_params['pick_id'])
    pick.player_id = create_params['player_id']
    if pick.save
      redirect_to :back
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
    Pick.execute_trade(update_params)
    redirect_to action: :edit, status: 303
  end

  private

  def create_params
    params.require(:pick).permit(:pick_id, :player_id)
  end

  def edit_params
    params.require(:league_id)
  end

  def update_params
    params.permit(picks: [team_one_picks: [], team_two_picks: []]).require(:picks)
  end
end
