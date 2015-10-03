class DraftsController < ApplicationController
  def show
    @league = League.find(draft_params)
    @teams = @league.teams.sort_by(&:draft_pick)
    @picks = Pick.joins('LEFT JOIN `players` ON picks.player_id = players.id').select(
      'picks.*, players.first_name as player_first_name, players.last_name as player_last_name'
    )
    @players = Player.undrafted(@league).sort_by { |p| [p.last_name, p.first_name] }
    @positions = Sport.get_positions(Sport.find(@league.sport.id))
    update_draft_status
  end

  private

  def draft_params
    params.require(:league_id)
  end

  def update_draft_status
    completed_draft_status_id = DraftStatus.find_by(description: 'Complete').id
    in_progress_draft_status_id = DraftStatus.find_by(description: 'In Progress').id
    not_started_draft_status_id = DraftStatus.find_by(description: 'Not Started').id
    picks_remaining = @picks.where(player_id: nil).length

    if @league.draft_status_id == not_started_draft_status_id ||
      (picks_remaining > 0 && @league.draft_status_id == completed_draft_status_id)
      @league.draft_status_id = in_progress_draft_status_id
      @league.save
    elsif picks_remaining == 0 && @league.draft_status_id == in_progress_draft_status_id
      @league.draft_status_id = completed_draft_status_id
      @league.save
    end
  end
end
