require 'rails_helper'

feature 'Non-authenticated user visits the application' do
  before do
    visit root_path
  end

  scenario 'is redirected to the sign in page' do
    expect(current_path).to eq new_user_session_path
  end

  scenario 'can register an account' do
    click_link 'Register'

    expect(page).to have_no_link 'Register'

    fill_in 'First name', with: 'Test'
    fill_in 'Last name', with: 'User'
    fill_in 'Email', with: 'test-user@example.com'
    fill_in 'Password', with: 'sufficientpassword'
    fill_in 'Password confirmation', with: 'sufficientpassword'
    click_button 'Register'

    expect(page).to have_content 'Welcome! You have registered successfully.'
    expect(current_path).to eq root_path
  end
end
