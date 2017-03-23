class DraftsController < ApplicationController
  before_action :ensure_draft_has_started

  def show
    @current_pick = league.current_pick.try(:attributes).try(:camelize)
    @current_team = league.teams
                          .select(:id, :user_id)
                          .find_by(user_id: current_user.id)
                          .try(:attributes).try(:camelize)
    @league = league
    @teams = league.teams.order(:draft_pick).select(:id, :name)
    @picks = league.picks.order(:id).includes(:player)
    @players = league.undrafted_players
                     .order(:last_name, :first_name)
                     .select(
                       :first_name,
                       :id,
                       :last_name,
                       :position,
                       :team,
                       :injury,
                       :headline,
                       :photo_url
                     )
    @positions = league.sport.position_options
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
