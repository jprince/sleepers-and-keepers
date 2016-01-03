class DraftsController < ApplicationController
  def show
    @data = Draft.state(draft_params)
  end

  private

  def draft_params
    params.require(:league_id)
  end
end
