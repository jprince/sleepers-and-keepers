module Pages
  class DraftRoom < Base
    def has_players?
      has_css? '.player'
    end

    def has_selected_player?(player_name)
      first_ticker_box = first('.pick')
      first_ticker_box.has_text? player_name
    end

    def has_team_on_the_clock?(team_name)
      has_css?('#on-the-clock', text: team_name)
    end

    def has_teams_in_ticker?(team_names)
      team_names.all? do |team|
        has_css?('.pick', text: team)
      end
    end
  end
end
