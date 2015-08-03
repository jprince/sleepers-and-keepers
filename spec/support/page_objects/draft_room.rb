module Pages
  class DraftRoom < Base
    def first_player_name
      "#{ Player.first.last_name}, #{ Player.first.first_name }"
    end

    def has_no_selected_player?(player_name)
      first_ticker_box = first('.pick')
      first_ticker_box.has_no_text? player_name
    end

    def has_no_undo_pick_button?
      has_no_css? '#undo-last-pick'
    end

    def has_players?
      has_css? '.player'
    end

    def has_recent_picks_in_ticker?(team_names)
      team_names.all? { |team| has_css?('.recent-picks .pick', text: team) }
    end

    def has_selected_player?(player_name)
      first_ticker_box = first('.pick')
      first_ticker_box.has_text? player_name
    end

    def has_team_on_the_clock?(team_name)
      has_text? "On the clock: #{team_name}"
    end

    def has_upcoming_picks_in_ticker?(team_names)
      team_names.all? { |team| has_css?('.upcoming-picks .pick', text: team) }
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

    def undo_last_pick
      find('#undo-last-pick').click
    end
  end
end
