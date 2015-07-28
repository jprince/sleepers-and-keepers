require 'spec_helper'

feature 'League manager' do
  before do
    @manager = create(:user)
    sign_in @manager
  end

  scenario 'can generate draft picks when the league is full' do
    league = create(:football_league, user: @manager)
    navigate_to_league
    expect(league_on_page).to have_no_link 'Set draft order'

    fill_league league
    reload_page

    click_link 'Set draft order'
    click_button 'Generate draft picks'
    expect(league_on_page).to have_empty_draft_results
  end

  scenario 'can set draft order' do
    league = create(:football_league, user: @manager)
    create(:team, league: league)
    11.times do
      owner = create(:user)
      create(:team, league: league, user: owner)
    end

    navigate_to_league
    click_link 'Set draft order'

    fill_in 'teams[1][draft_pick]', with: 10
    fill_in 'teams[3][draft_pick]', with: 12
    click_button 'Save'

    expect(page).to have_revised_draft_order
  end

  scenario 'can trade draft picks after picks are generated', js: true do
    league = create(:football_league, user: @manager)
    fill_league league
    navigate_to_league
    expect(league_on_page).to have_no_link 'Trade picks'

    click_link 'Set draft order'
    click_button 'Generate draft picks'
    click_link 'League Home'
    click_link 'Trade picks'

    trade_picks_page.select_first_team_pick('Rd: 1, Pick: 1 (1 overall)')
    trade_picks_page.select_first_team_pick('Rd: 2, Pick: 12 (24 overall)')
    trade_picks_page.select_second_team_pick('Rd: 1, Pick: 2 (2 overall)')
    trade_picks_page.select_second_team_pick('Rd: 2, Pick: 11 (23 overall)')
    click_button 'Perform Trade'

    expect(trade_picks_page).to have_updated_team_picks
  end

  scenario 'can manage keepers after picks are generated', js: true do
    league = create(:football_league, user: @manager)
    fill_league league
    create_player_pool
    navigate_to_league
    expect(league_on_page).to have_no_link 'Set keepers'

    click_link 'Set draft order'
    click_button 'Generate draft picks'
    click_link 'League Home'
    click_link 'Set keepers'

    first_team = Team.first
    first_qb = Player.where(position: 'QB').first
    first_qb_name = "#{first_qb.last_name}, #{first_qb.first_name}"

    expect(keeper_page).to have_selected_team(first_team.name)
    expect(keeper_page).to have_selected_pick('Rd: 1, Pick: 12 (12 overall)')
    expect(keeper_page).to have_selected_position('ALL')

    keeper_page.select_position('QB')
    expect(keeper_page).to have_selected_player(first_qb_name)

    last_team = Team.last
    first_rb = Player.where(position: 'RB').first
    first_rb_name = "#{first_rb.last_name}, #{first_rb.first_name}"
    last_teams_first_pick = 'Rd: 1, Pick: 1 (1 overall)'

    keeper_page.select_team(last_team.name)
    expect(keeper_page).to have_selected_pick(last_teams_first_pick)
    keeper_page.select_position('RB')
    expect(keeper_page).to have_selected_player(first_rb_name)

    click_button 'Save'
    expect(keeper_page).to have_keeper(first_rb_name, last_teams_first_pick)

    click_link 'League Home'
    click_link 'View draft order'
    expect(league_on_page).to have_drafted_player(first_rb_name)

    click_link 'League Home'
    click_link 'Set keepers'
    expect(keeper_page).to have_no_keepers

    keeper_page.select_team(last_team.name)
    expect(keeper_page).to have_keeper(first_rb_name, last_teams_first_pick)
    keeper_page.remove_first_keeper
    expect(keeper_page).to have_no_keepers
  end

  scenario 'can start the draft when the league is full' do
    create(:draft_status, description: 'In Progress')
    league = create(:football_league, user: @manager)
    create(:team, league: league, user: @manager)

    navigate_to_league
    expect(league_on_page).to have_no_link 'Start draft'
    fill_league league

    reload_page
    click_link 'Start draft'
    expect(league_on_page).to have_content 'Fantasy Sports Dojo Draft'
  end

  scenario 'can join a draft in progress' do
    create(:football_league, :with_draft_in_progress, user: @manager)

    navigate_to_league
    expect(league_on_page).to have_link 'Join draft'
  end

  scenario 'cannot start or join a completed draft' do
    create(:football_league, :with_draft_complete, user: @manager)

    navigate_to_league
    expect(league_on_page).to have_no_link 'Start draft'
    expect(league_on_page).to have_no_link 'Join draft'
  end

  scenario 'can undo picks during the draft', js: true do
    league = create(:football_league, :with_draft_in_progress, rounds: 2, user: @manager)
    create(:team, league: league, user: @manager)
    create_player_pool
    fill_league league
    generate_draft_picks(league)
    draft_room.select_player_with_first_pick

    sign_in @manager
    navigate_to_league
    league_on_page.enter_draft
    team_with_second_pick = league_on_page.league_team_with_pick(league, 2).name
    expect(draft_room).to have_team_on_the_clock(team_with_second_pick)
    expect(draft_room).to have_selected_player(draft_room.first_player_name)

    draft_room.undo_last_pick
    team_with_first_pick = league_on_page.league_team_with_pick(league, 1).name
    expect(draft_room).to have_team_on_the_clock(team_with_first_pick)
    expect(draft_room).to have_no_selected_player(draft_room.first_player_name)
  end
end

def has_revised_draft_order?
  team_one_pick = find('input#team-1')
  team_three_pick = find('input#team-3')

  teams_have_correct_draft_picks_set =
    team_one_pick.value == '10' &&
    team_three_pick.value == '12'

  draft_order_inputs = all('#draft-order input')
  teams_in_correct_order =
    draft_order_inputs[9] == team_one_pick &&
    draft_order_inputs[11] == team_three_pick

  teams_have_correct_draft_picks_set && teams_in_correct_order
end

def draft_room
  @draft_room ||= Pages::DraftRoom.new
end

def keeper_page
  @keeper_page ||= Pages::KeeperPage.new
end

def league_on_page
  @league_on_page ||= Pages::League.new
end

def trade_picks_page
  @trade_picks_page ||= Pages::TradePicksPage.new
end
