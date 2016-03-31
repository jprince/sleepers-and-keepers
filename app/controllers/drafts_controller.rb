class DraftsController < ApplicationController
  before_action :ensure_draft_has_started

  def show
    @league = league
    @teams = league.teams.sort_by(&:draft_pick)
    @picks = league.picks.joins('LEFT JOIN players ON picks.player_id = players.id').select(
      'picks.*, players.first_name as player_first_name, players.last_name as player_last_name'
    ).order(:id)
    @players = Player.undrafted(league).sort_by { |p| [p.last_name, p.first_name] }
    @positions = Sport.find(league.sport.id).position_options
  end

  private

  def ensure_draft_has_started
    return unless league.draft_not_started?
    league.begin_draft
  end

  def league
    @league ||= League.find(league_id)
  end

  def league_id
    params.require(:league_id)
  end
end
