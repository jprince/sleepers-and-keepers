class DraftRoomBroadcastJob < ActiveJob::Base
  queue_as :default

  def perform(pick)
    ActionCable.server.broadcast 'draft_room_channel', data: render_draft_room(pick.league.id)
  end

  private
    def render_draft_room(league_id)
      ApplicationController.renderer.render(template: 'drafts/show.json.jbuilder', locals: { data: Draft.state(league_id) })
    end
end
