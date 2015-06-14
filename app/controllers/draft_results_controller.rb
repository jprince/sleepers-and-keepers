class DraftResultsController < ApplicationController
  def create
    Pick.create_picks(League.find(league_id))
    redirect_to league_draft_results_path
  end

  def show
    @picks = League.find(league_id).picks
  end

  private

  def league_id
    params.require(:league_id)
  end
end
