module Features
  module DataPreparationHelpers
    def fill_league(league)
      league.size.times do
        owner = FactoryGirl.create(:user)
        FactoryGirl.create(:team, league_id: league.id, user_id: owner.id)
      end
    end
  end
end
