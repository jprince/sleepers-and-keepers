module Features
  module DataPreparationHelpers
    def create_player_pool
      football = Sport.find_by(name: 'Football')
      FactoryGirl.create(:player, sport: football)
      2.times { FactoryGirl.create(:player, position: 'QB', sport: football) }
      2.times { FactoryGirl.create(:player, position: 'RB', sport: football) }
      2.times { FactoryGirl.create(:player, position: 'WR', sport: football) }
      2.times { FactoryGirl.create(:player, position: 'TE', sport: football) }
      2.times { FactoryGirl.create(:player, position: 'K', sport: football) }
      2.times { FactoryGirl.create(:player, position: 'DST', sport: football) }
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
