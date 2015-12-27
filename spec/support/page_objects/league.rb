module Pages
  class League < Base
    def enter_draft
      click_link 'Join Draft'
    end

    def has_drafted_player?(player_name)
      has_css?('.player', text: player_name)
    end

    def has_empty_draft_results?
      has_text_in_column?('round', 1) &&
        has_text_in_column?('round-pick', 1) &&
        has_text_in_column?('team', Team.first.name) &&
        has_text_in_column?('player', '')
    end

    def league_team_with_pick(league, round_pick_number)
      league.teams.where(draft_pick: round_pick_number).first
    end

    def set_keeper(pick, player)
      pick.player_id = player.id
      pick.keeper = true
      pick.save
    end
  end
end
