require 'spec_helper'

feature 'Leagues - ' do
  before do
    create(:draft_status)
    create(:sport)
    sign_in create(:user)
  end

  scenario 'can be created by any registered user' do
    click_link 'New League'

    fill_in 'Name', with: 'My New League'
    fill_in 'Sport', with: 'Football'
    fill_in 'Password', with: 'topsecret1'
    fill_in 'Size', with: 12
    fill_in 'Rounds', with: 15

    click_button 'Create'
    expect(page).to have_content 'Created successfully'
    expect(page).to have_content 'My New League'
  end
end
