require 'rails_helper'

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

    click_link 'Set Draft Order'
    click_link 'Generate Draft Picks'
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
    click_link 'Set Draft Order'
    wait_for_page_ready do
      fill_in "teams[#{Team.all.order(:id)[0].id}][draft_pick]", with: 10
      fill_in "teams[#{Team.all.order(:id)[2].id}][draft_pick]", with: 12
      click_button 'Save'
    end

    expect(draft_order_page).to have_revised_draft_order
  end

  scenario 'can trade draft picks after picks are generated', js: true do
    league = create(:football_league, user: @manager)
    fill_league league
    navigate_to_league
    expect(league_on_page).to have_no_link 'Trade Picks'

    click_link 'Set Draft Order'
    click_link 'Generate Draft Picks'
    navigate_to_league_home
    click_link 'Trade Picks'

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

    click_link 'Set Draft Order'
    click_link 'Generate Draft Picks'
    navigate_to_league_home
    click_link 'Set Keepers'

    expect(keeper_page).to have_selected_team(Team.last.name)
    expect(keeper_page).to have_selected_pick('Rd: 1, Pick: 1 (1 overall)')
    expect(keeper_page).to have_selected_position('ALL')

    keeper_page.select_position('QB')
    first_qb = league.sport.players.where(position: 'QB').first
    expect(keeper_page).to have_selected_player league_on_page.get_player_name(first_qb)

    last_team = Team.first
    first_rb = league.sport.players.where(position: 'RB').first
    first_rb_name = league_on_page.get_player_name(first_rb)
    last_teams_first_pick = 'Rd: 1, Pick: 12 (12 overall)'

    keeper_page.select_team(last_team.name)
    expect(keeper_page).to have_selected_pick(last_teams_first_pick)
    keeper_page.select_position('RB')
    expect(keeper_page).to have_selected_player(first_rb_name)

    click_button 'Save'
    expect(keeper_page).to have_keeper(first_rb_name, last_teams_first_pick)

    navigate_to_league_home
    click_link 'View Draft Order'
    expect(league_on_page).to have_drafted_player(first_rb_name)

    navigate_to_league_home
    click_link 'Set Keepers'
    expect(keeper_page).to have_no_keepers

    keeper_page.select_team(last_team.name)
    expect(keeper_page).to have_keeper(first_rb_name, last_teams_first_pick)
    keeper_page.remove_first_keeper
    expect(keeper_page).to have_no_keepers
  end

  scenario 'can start the draft when the league is full and picks have been generated' do
    league = create(:football_league, user: @manager)
    create(:team, league: league, user: @manager)

    navigate_to_league
    expect(league_on_page).to have_no_link 'Start Draft'
    fill_league league

    reload_page
    expect(league_on_page).to have_no_link 'Start Draft'

    click_link 'Set Draft Order'
    click_link 'Generate Draft Picks'
    navigate_to_league_home
    click_link 'Start Draft'
    expect(league_on_page).to have_content 'Fantasy Sports Dojo Draft'
  end

  scenario 'can join a draft in progress' do
    create(:football_league, :with_draft_in_progress, user: @manager)

    navigate_to_league
    expect(league_on_page).to have_link 'Join Draft'
  end

  scenario 'cannot start or join a completed draft' do
    create(:football_league, :with_draft_complete, user: @manager)

    navigate_to_league
    expect(league_on_page).to have_no_link 'Start Draft'
    expect(league_on_page).to have_no_link 'Join Draft'
  end

  describe 'draft room', js: true do
    before do
      @league = create(:football_league, :with_draft_in_progress, rounds: 2, user: @manager)
      create(:team, league: @league, user: @manager)
      create_player_pool
      fill_league @league
      generate_draft_picks(@league)
      sign_in @manager

      navigate_to_league
    end

    scenario 'can draft players even when not on the clock' do
      league_on_page.enter_draft
      draft_room.select_player(draft_room.first_player_name)
      expect(draft_room).to have_selected_player(draft_room.first_player_name)

      team_with_second_pick = league_on_page.league_team_with_pick(@league, 2).name
      expect(draft_room).to have_team_on_the_clock(team_with_second_pick)
    end

    scenario 'can undo picks during the draft' do
      draft_room.select_player_with_first_pick
      league_on_page.enter_draft

      team_with_second_pick = league_on_page.league_team_with_pick(@league, 2).name
      expect(draft_room).to have_team_on_the_clock(team_with_second_pick)
      expect(draft_room).to have_selected_player(draft_room.first_player_name)

      draft_room.undo_last_pick
      team_with_first_pick = league_on_page.league_team_with_pick(@league, 1).name
      expect(draft_room).to have_team_on_the_clock(team_with_first_pick)
      expect(draft_room).to have_no_selected_player(draft_room.first_player_name)
    end

    scenario 'can pause and resume the timer' do
      league_on_page.enter_draft

      draft_room.toggle_timer_pause
      paused_time_remaining = draft_room.time_remaining
      draft_room.let_pick_timer_run
      expect(draft_room.time_remaining).to eq paused_time_remaining
      draft_room.toggle_timer_pause
      draft_room.let_pick_timer_run
      expect(draft_room.time_remaining).to be < paused_time_remaining
    end

    scenario 'time remaining resets after a pick is undone' do
      draft_room.select_player_with_first_pick
      league_on_page.enter_draft

      draft_room.let_pick_timer_run(3)
      time_remaining_before_undoing_pick = draft_room.time_remaining
      draft_room.undo_last_pick
      expect(draft_room.time_remaining).to be > time_remaining_before_undoing_pick
    end
  end
end

def draft_order_page
  @draft_order_page ||= Pages::DraftOrderPage.new
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
