class DraftRoomBroadcastJob < ActiveJob::Base
  queue_as :default

  def perform(draft_state)
    ActionCable.server.broadcast(
      "draft_room_channel_#{pick.league.id}",
      data: draft_state
    )
  end
end
