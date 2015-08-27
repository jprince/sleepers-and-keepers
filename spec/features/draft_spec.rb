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

  scenario 'team on the clock can draft a player' do
    team_with_first_pick = league_on_page.league_team_with_pick(@league, 1)
    user_with_first_pick = team_with_first_pick.user
    sign_in user_with_first_pick
    navigate_to_league
    league_on_page.enter_draft

    draft_room.select_player(draft_room.first_player_name)
    expect(draft_room).to have_selected_player(draft_room.first_player_name)

    team_with_second_pick = league_on_page.league_team_with_pick(@league, 2).name
    expect(draft_room).to have_team_on_the_clock(team_with_second_pick)
  end

  describe 'draft ticker' do
    before do
      sign_in @league_member
      navigate_to_league
      league_on_page.enter_draft

      Player.first(8).each do |player|
        draft_room.select_player("#{ player.last_name}, #{ player.first_name }")
      end
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

    scenario 'shows time remaining for current pick' do
      expect(draft_room.time_remaining).to be_between(0, 120)
    end

    scenario 'time remaining resets after a pick is made' do
      draft_room.let_pick_timer_run
      time_remaining_before_making_pick = draft_room.time_remaining
      draft_room.select_player(draft_room.first_available_player_name)
      expect(draft_room.time_remaining).to be > time_remaining_before_making_pick
    end

    scenario 'time remaining does not reset when the user filters by position' do
      draft_room.let_pick_timer_run
      time_remaining_before_filtering = draft_room.time_remaining
      draft_room.select_position 'QB'
      wait_for_page_ready(1) do
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
