require 'spec_helper'

feature 'League draft room', js: true do
  before do
    league = create(:football_league, :with_draft_in_progress, rounds: 2)
    league_member = create(:user)
    create(:team, league: league, user: league_member)
    create_player_pool
    fill_league league
    generate_draft_picks(league)
    sign_in league_member
    navigate_to_league
    league_on_page.enter_draft
  end

  scenario 'contains all available players' do
    expect(draft_room).to have_players
  end

  scenario 'shows the team that is currently on the clock' do
    team_with_first_pick = Pick.first.team.name
    expect(draft_room).to have_team_on_the_clock(team_with_first_pick)
  end

  scenario 'shows upcoming draft picks' do
    top_six_teams = Pick.first(6).map { |pick| pick.team.name }
    expect(draft_room).to have_teams_in_ticker(top_six_teams)
  end
end

def draft_room
  @draft_room ||= Pages::DraftRoom.new
end

def league_on_page
  @league_on_page ||= Pages::League.new
end
