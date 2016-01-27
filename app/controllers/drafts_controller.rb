class DraftsController < ApplicationController
  def show
    @channel_broadcast = false
    @data = Draft.state(draft_params)
  end

  private

  def draft_params
    params.require(:league_id)
  end
end
