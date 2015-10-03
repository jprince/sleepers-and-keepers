module Features
  module DataPreparationHelpers
    def create_player_pool
      FactoryGirl.create(:player, sport: Sport.last)
      2.times { FactoryGirl.create(:player, position: 'QB', sport: Sport.last) }
      2.times { FactoryGirl.create(:player, position: 'RB', sport: Sport.last) }
      2.times { FactoryGirl.create(:player, position: 'WR', sport: Sport.last) }
      2.times { FactoryGirl.create(:player, position: 'TE', sport: Sport.last) }
      2.times { FactoryGirl.create(:player, position: 'K', sport: Sport.last) }
      2.times { FactoryGirl.create(:player, position: 'DST', sport: Sport.last) }
    end

    def fill_league(league)
      teams_needed_count = league.size - league.teams.length
      teams_needed_count.times do
        owner = FactoryGirl.create(:user)
        FactoryGirl.create(:team, league: league, user: owner)
      end
    end

    def generate_draft_picks(league)
      Pick.create_picks(League.find(league.id))
    end

    def use_league_draft_picks(league)
      league.picks.each do |pick|
        pick.player_id = Player.first.id
        pick.save
      end
    end
  end
end
