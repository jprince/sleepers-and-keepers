module Features
  module NavigationHelpers
    def navigate_to_league(name = 'Fantasy Sports Dojo')
      click_link 'View Existing Leagues'
      click_link name
    end
  end
end
