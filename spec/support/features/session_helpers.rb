module Features
  module SessionHelpers
    include Warden::Test::Helpers
    Warden.test_mode!

    # Use this method for integration specs that just want a logged in
    # user and you don't care how.
    def sign_in(user)
      login_as(user, scope: :user)
      visit root_path
    end
  end
end
