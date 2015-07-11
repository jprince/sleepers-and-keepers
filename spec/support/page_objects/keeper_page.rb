module Pages
  class KeeperPage < Base
    def has_keeper?(player_name, pick)
      has_css?('.keeper', text: "#{player_name} - #{pick}")
    end

    def has_no_keepers?
      has_no_css?('.keeper')
    end

    def has_selected_pick?(pick)
      has_select?('pick-select', selected: pick)
    end

    def has_selected_player?(player_name)
      has_select?('player-select', selected: player_name)
    end

    def has_selected_position?(position)
      has_select?('position-select', selected: position)
    end

    def has_selected_team?(team_name)
      has_select?('team-select', selected: team_name)
    end

    def remove_first_keeper
      find('a.remove').click
    end

    def select_position(position)
      select(position, from: 'position-select')
    end

    def select_team(team_name)
      select(team_name, from: 'team-select')
    end
  end
end
