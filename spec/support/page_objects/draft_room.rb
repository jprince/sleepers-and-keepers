module Pages
  class DraftRoom < Base
    def first_available_player_name
      first('.player').find('.select').text
    end

    def first_player_name
      get_player_name(Player.first)
    end

    def has_keeper_in_upcoming_picks?(player_name)
      within find('.upcoming-picks') do
        has_player_in_ticker player_name
      end
    end

    def has_link_to_draft_results?
      has_link? 'View Results'
    end

    def has_no_player?(player)
      has_no_css?('.player', text: get_player_name(player))
    end

    def has_no_selected_player?(player_name)
      first_ticker_box = first('.pick')
      first_ticker_box.has_no_text? player_name
    end

    def has_no_timer_pause_button?
      has_no_css? '#toggle-pause-pick-timer'
    end

    def has_no_undo_pick_button?
      has_no_css? '#undo-last-pick'
    end

    def has_player?(player)
      has_css?('.player', text: get_player_name(player))
    end

    def has_players?
      has_css? '.player'
    end

    def has_recent_picks_in_ticker?(team_names)
      team_names.all? { |team| has_css?('.recent-picks .pick', text: team) }
    end

    def has_search_text?(search_text)
      has_field?('player-search', with: search_text)
    end

    def has_selected_player?(player_name)
      has_player_in_ticker player_name
    end

    def has_team_on_the_clock?(team_name)
      has_text? "On the clock: #{team_name}"
    end

    def has_upcoming_picks_in_ticker?(team_names)
      team_names.all? { |team| has_css?('.upcoming-picks .pick', text: team) }
    end

    def let_pick_timer_run(sec = 2)
      sleep sec
    end

    def search_for(search_text)
      fill_in('player-search', with: search_text)
    end

    def select_player(player_name)
      click_link player_name
      sleep 0.25
    end

    def select_player_with_first_pick
      first_pick = Pick.first
      first_pick.player_id = Player.first.id
      first_pick.save
    end

    def toggle_timer_pause
      find('#toggle-pause-pick-timer').click
    end

    def time_remaining
      find('#time-remaining').text.to_i
    end

    def undo_last_pick
      find('#undo-last-pick').click
      sleep 0.25
    end

    private

    def has_player_in_ticker(player_name)
      first_ticker_box = first('.pick')
      first_ticker_box.has_text? player_name
    end
  end
end
