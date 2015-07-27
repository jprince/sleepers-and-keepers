class DraftsController < ApplicationController
  def show
    @league = League.find(draft_params)
    @current_team_id = @league.teams.find_by(user_id: current_user.id).id
    @teams = @league.teams.sort_by(&:draft_pick)
    @picks = @league.picks.joins('LEFT JOIN players ON picks.player_id = players.id').select(
      'picks.*, players.first_name as player_first_name, players.last_name as player_last_name'
    ).order(:id)
    @players = Player.undrafted(@league).sort_by { |p| [p.last_name, p.first_name] }
    @positions = Sport.get_positions(Sport.find(@league.sport.id))
    @league.update_draft_status
  end

  private

  def draft_params
    params.require(:league_id)
  end
end
