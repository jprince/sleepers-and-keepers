class DraftRoomBroadcastJob < ActiveJob::Base
  queue_as :default

  def perform(draft_state)
    ActionCable.server.broadcast(
      "draft_room_channel_#{draft_state['leagueId']}",
      data: draft_state
    )
  end
end
