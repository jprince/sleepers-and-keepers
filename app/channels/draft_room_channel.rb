# Be sure to restart your server when you modify this file.
# Action Cable runs in an EventMachine loop that does not support auto reloading.
class DraftRoomChannel < ApplicationCable::Channel
  def subscribed
    stop_all_streams
    stream_from "draft_room_channel_#{params[:league_id]}"
  end

  def unsubscribed
    stop_all_streams
  end
end
