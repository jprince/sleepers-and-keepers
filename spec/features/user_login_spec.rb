require 'rails_helper'

feature 'Non-authenticated user visits the application' do
  scenario 'can log in with an existing account' do
    user = create(:user)
    visit root_path

    expect(page).to have_no_link 'Log in'

    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'

    expect(page).to have_content 'Signed in successfully'
    expect(current_path).to eq root_path
  end
end

feature 'Authenticated user' do
  scenario 'can log out' do
    sign_in create(:user)
    click_link 'Logout'
    expect(page).to have_content 'You need to sign in or register before continuing'
    expect(current_path).to eq new_user_session_path
  end
end
