module Features
  module NavigationHelpers
    def navigate_to_league(name)
      click_link 'View Existing Leagues'
      click_link name
    end
  end
end
