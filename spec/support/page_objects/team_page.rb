module Pages
  class TeamPage < Base
    def has_player_at_position?(player_name, position)
      within ".#{position.downcase}" do
        has_css? 'li', text: player_name
      end
    end
  end
end
