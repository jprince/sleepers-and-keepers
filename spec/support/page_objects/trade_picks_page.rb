module Pages
  class TradePicksPage < Base
    def has_updated_team_picks?
      former_team_one_picks = ['Rd: 1, Pick: 1 (1 overall)', 'Rd: 2, Pick: 12 (24 overall)']
      former_team_two_picks = ['Rd: 1, Pick: 2 (2 overall)', 'Rd: 2, Pick: 11 (23 overall)']
      has_select?('team-one-pick-select', with_options: former_team_two_picks) &&
      has_select?('team-two-pick-select', with_options: former_team_one_picks)
    end

    def select_first_team_pick(pick)
      select(pick, from: 'team-one-pick-select')
    end

    def select_second_team_pick(pick)
      select(pick, from: 'team-two-pick-select')
    end
  end
end
