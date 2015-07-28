require 'spec_helper'

feature 'League members' do
  before do
    @member = create(:user)
    sign_in @member
  end

  scenario 'can view teams' do
    league = create(:football_league)
    team = create(:team, league: league, user: @member)
    drafted_player = create(:player, sport: league.sport)
    create(:pick, player: drafted_player, team: team)

    navigate_to_league
    click_link 'Teams'
    click_link team.name

    drafted_player_name = "#{drafted_player.last_name}, #{drafted_player.first_name}"
    expect(team_page).to have_player_at_position(drafted_player_name, drafted_player.position)
  end

  scenario 'can join a draft in progress' do
    league = create(:football_league, :with_draft_in_progress)
    create(:team, league: league, user: @member)

    navigate_to_league
    expect(page).to have_link 'Join draft'
  end

  scenario 'cannot join a completed draft' do
    league = create(:football_league, :with_draft_complete)
    create(:team, league: league, user: @member)

    navigate_to_league
    expect(page).to have_no_link 'Join draft'
  end

  scenario 'has no admin rights' do
    league = create(:football_league)
    create(:team, league: league, user: @member)

    navigate_to_league
    expect(page).to have_no_link 'Set draft order'
    expect(page).to have_no_link 'Set keepers'
    expect(page).to have_no_link 'Start draft'
  end

  scenario 'cannot undo picks during the draft', js: true do
    league = create(:football_league, :with_draft_in_progress, rounds: 2)
    create(:team, league: league, user: @member)
    create_player_pool
    fill_league league
    generate_draft_picks(league)

    navigate_to_league
    league_on_page.enter_draft
    wait_for_page_ready do
      expect(draft_room).to have_no_button 'Undo last pick'
    end
  end
end

def draft_room
  @draft_room ||= Pages::DraftRoom.new
end

def league_on_page
  @league_on_page ||= Pages::League.new
end

def team_page
  @team_page ||= Pages::TeamPage.new
end
