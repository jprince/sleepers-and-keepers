require 'spec_helper'

feature 'League draft room', js: true do
  before do
    @league = create(:football_league, :with_draft_in_progress, rounds: 2)
    @league_member = create(:user)
    create(:team, league: @league, user: @league_member)
    create_player_pool
    fill_league @league
    generate_draft_picks(@league)
  end

  scenario 'contains all available players' do
    sign_in @league_member
    navigate_to_league
    league_on_page.enter_draft

    expect(draft_room).to have_players
  end

  scenario 'shows the team that is currently on the clock' do
    sign_in @league_member
    navigate_to_league
    league_on_page.enter_draft

    team_with_first_pick = Pick.first.team.name
    expect(draft_room).to have_team_on_the_clock(team_with_first_pick)
  end

  scenario 'shows upcoming draft picks' do
    sign_in @league_member
    navigate_to_league
    league_on_page.enter_draft

    top_seven_teams = Pick.first(7).map { |pick| pick.team.name }
    expect(draft_room).to have_teams_in_ticker(top_seven_teams)
  end

  scenario 'team on the clock can draft a player' do
    team_with_first_pick = @league.teams.where(draft_pick: 1).first
    user_with_first_pick = team_with_first_pick.user
    sign_in user_with_first_pick
    navigate_to_league
    league_on_page.enter_draft

    first_player_name = "#{ Player.first.last_name}, #{ Player.first.first_name }"
    click_link first_player_name
    expect(draft_room).to have_selected_player(first_player_name)

    team_with_second_pick = @league.teams.where(draft_pick: 2).first.name
    expect(draft_room).to have_team_on_the_clock(team_with_second_pick)
  end
end

def draft_room
  @draft_room ||= Pages::DraftRoom.new
end

def league_on_page
  @league_on_page ||= Pages::League.new
end
