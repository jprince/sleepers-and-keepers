# Be sure to restart your server when you modify this file.
# Action Cable runs in an EventMachine loop that does not support auto reloading.
class DraftRoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "draft_room_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def refresh(data)
    ActionCable.server.broadcast 'draft_room_channel', data: data['refreshedData']
  end
end
