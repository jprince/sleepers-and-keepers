require 'spec_helper'

feature 'Teams' do
  before do
    create(:league)
    sign_in create(:user)
  end

  scenario 'can be created within a league' do
    navigate_to_league('Fantasy Sports Dojo')
    click_link 'New Team'

    fill_in 'Name', with: 'My New Team'
    fill_in 'Short name', with: 'MNT'

    click_button 'Create'
    expect(page).to have_content 'Created successfully'
    expect(page).to have_content 'My New Team'
    expect(page).to have_content 'Owner: Test User'
  end

  scenario 'cannot create another team if they already have one' do
    create(:team)
    navigate_to_league('Fantasy Sports Dojo')

    expect(page).to have_no_content 'New Team'
  end

  scenario 'can view a list of teams' do
    create(:team)
    @other_owner = create(:user, email: 'other-user@example.com')
    @other_owner_team = create(:team, user_id: @other_owner.id, name: 'The Bad Guy')

    navigate_to_league('Fantasy Sports Dojo')
    click_link 'Teams'
    expect(page).to have_content 'Frontrunners'
    expect(page).to have_content 'The Bad Guy'
  end
end
