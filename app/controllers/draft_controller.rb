class DraftController < ApplicationController
  def show
    @league = League.find(draft_params)
    if @league.draft_status_id == DraftStatus.find_by(description: 'Not Started').id
      start_draft
    end
    @teams = @league.teams.sort_by(&:draft_pick)
    @players = Sport.find(@league.sport_id).players.sort_by { |p| [p.last_name, p.first_name] }
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
