class DraftsController < ApplicationController
  def show
    @league = League.find(draft_params)
    if @league.draft_status_id == DraftStatus.find_by(description: 'Not Started').id
      start_draft
    end
    @teams = @league.teams.sort_by(&:draft_pick)
    @picks = Pick.joins('LEFT JOIN `players` ON picks.player_id = players.id').select(
      'picks.*, players.first_name as player_first_name, players.last_name as player_last_name'
    )
    @players = Player.undrafted(@league).sort_by { |p| [p.last_name, p.first_name] }
    @positions = Sport.get_positions(Sport.find(@league.sport.id))
  end

  private

  def draft_params
    params.require(:league_id)
  end

  def start_draft
    @league.draft_status_id = DraftStatus.find_by(description: 'In Progress').id
    @league.save
  end
end
