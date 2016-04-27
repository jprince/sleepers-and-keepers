require 'rails_helper'

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

  scenario 'allows users to search for players' do
    matched_player = create(:player, last_name: 'match', sport: @league.sport)
    unmatched_player = create(:player, last_name: 'nope', sport: @league.sport)
    user_with_first_pick = league_on_page.league_team_with_pick(@league, 1).user
    sign_in user_with_first_pick
    navigate_to_league
    league_on_page.enter_draft

    expect(draft_room).to have_player matched_player
    expect(draft_room).to have_player unmatched_player

    draft_room.search_for 'mat'
    wait_for_page_ready do
      expect(draft_room).to have_player matched_player
      expect(draft_room).to have_no_player unmatched_player
    end

    draft_room.select_player(draft_room.get_player_name(matched_player))
    expect(draft_room).to have_player unmatched_player
    expect(draft_room).to have_search_text ''
  end

  scenario 'team on the clock can draft a player' do
    user_with_first_pick = league_on_page.league_team_with_pick(@league, 1).user
    sign_in user_with_first_pick
    navigate_to_league
    league_on_page.enter_draft

    player_name = draft_room.get_player_name(Player.first)
    draft_room.select_player(player_name)
    expect(draft_room).to have_selected_player(player_name)

    team_with_second_pick = league_on_page.league_team_with_pick(@league, 2).name
    expect(draft_room).to have_team_on_the_clock(team_with_second_pick)
  end

  scenario 'team not on the clock cannot draft a player' do
    user_with_second_pick = league_on_page.league_team_with_pick(@league, 2).user
    sign_in user_with_second_pick
    navigate_to_league
    league_on_page.enter_draft

    expect(draft_room).to have_text 'Fantasy Sports Dojo Draft'
    expect(draft_room).to have_no_link draft_room.get_player_name(Player.first)
  end

  scenario 'completes the draft when no picks remain' do
    league = create(:football_league, :with_draft_in_progress, name: 'Nearly completed draft')
    league_member = create(:user)
    create(:team, league: league, user: league_member)
    fill_league league
    generate_draft_picks league
    select_players_with_picks(league, league.picks.first(11))

    sign_in league_member
    navigate_to_league(league.name)
    league_on_page.enter_draft
    draft_room.select_player(draft_room.get_player_name(Player.last))

    expect(draft_room).to have_link_to_draft_results
  end

  describe 'draft ticker' do
    context 'showing recent, current, and upcoming picks -' do
      before do
        select_players_with_picks(@league, @league.picks.first(8))
        sign_in @league_member
        navigate_to_league
        league_on_page.enter_draft
      end

      scenario 'shows the team that is currently on the clock' do
        team_with_ninth_pick = league_on_page.league_team_with_pick(@league, 9).name
        expect(draft_room).to have_team_on_the_clock(team_with_ninth_pick)
      end

      scenario 'shows recent draft picks' do
        top_eight_picks = Pick.first(8).map { |pick| pick.team.name }
        expect(draft_room).to have_recent_picks_in_ticker(top_eight_picks)
      end

      scenario 'shows upcoming draft picks' do
        picks_ten_thru_seventeen = Pick.where(overall_pick: 10..17).map { |pick| pick.team.name }
        expect(draft_room).to have_upcoming_picks_in_ticker(picks_ten_thru_seventeen)
      end
    end

    scenario 'keepers are shown in upcoming picks' do
      tenth_overall_pick = Pick.find_by(overall_pick: 10)
      first_qb = Player.where(position: 'QB').first

      league_on_page.set_keeper(tenth_overall_pick, first_qb)

      select_players_with_picks(@league, @league.picks.first(8))
      sign_in @league_member
      navigate_to_league
      league_on_page.enter_draft

      expect(draft_room).to have_keeper_in_upcoming_picks draft_room.get_player_name(first_qb)
    end

    scenario 'shows time remaining for current pick' do
      sign_in @league_member
      navigate_to_league
      league_on_page.enter_draft

      expect(draft_room.time_remaining).to be_between(0, 120)
    end

    scenario 'time remaining resets after a pick is made' do
      user_with_first_pick = league_on_page.league_team_with_pick(@league, 1).user
      sign_in user_with_first_pick
      navigate_to_league
      league_on_page.enter_draft

      draft_room.let_pick_timer_run(4)
      time_remaining_before_making_pick = draft_room.time_remaining
      draft_room.select_player(draft_room.get_player_name(Player.first))
      expect(draft_room.time_remaining).to be > time_remaining_before_making_pick
    end

    scenario 'time remaining does not reset when the user filters by position' do
      user_with_first_pick = league_on_page.league_team_with_pick(@league, 1).user
      sign_in user_with_first_pick
      navigate_to_league
      league_on_page.enter_draft

      draft_room.let_pick_timer_run
      time_remaining_before_filtering = draft_room.time_remaining
      draft_room.select_position 'QB'
      wait_for_page_ready(1.5) do
        expect(draft_room.time_remaining).to be < time_remaining_before_filtering
      end
    end
  end
end

def draft_room
  @draft_room ||= Pages::DraftRoom.new
end

def league_on_page
  @league_on_page ||= Pages::League.new
end
