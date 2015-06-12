require 'spec_helper'

feature 'League draft ' do
  before do
    league = create(:football_league, :with_draft_in_progress)
    league_member = create(:user)
    create(:team, league: league, user: league_member)
    create_player_pool
    fill_league league
    sign_in league_member
    navigate_to_league
    league_on_page.enter_draft
  end

  scenario 'room contains all available players' do
    expect(draft_room).to have_players
  end
end

def draft_room
  @draft_room ||= Pages::DraftRoom.new
end

def league_on_page
  @league_on_page ||= Pages::League.new
end
