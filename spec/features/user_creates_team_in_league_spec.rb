require 'spec_helper'

feature 'Teams' do
  before do
    create(:league)
    sign_in create(:user)
    navigate_to_league('Fantasy Sports Dojo')
  end

  scenario 'can be created within a league' do
    click_link 'New Team'

    fill_in 'Name', with: 'My New Team'
    fill_in 'Short name', with: 'MNT'

    click_button 'Create'
    expect(page).to have_content 'Created successfully'
    expect(page).to have_content 'My New Team'
    expect(page).to have_content 'Owner: Test User'
  end
end
