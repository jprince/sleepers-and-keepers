require 'rails_helper'

feature 'Team owners' do
  before do
    @member = create(:user)
    sign_in @member
  end

  scenario 'can join a league' do
    create(:football_league)
    navigate_to_league
    click_link 'New Team'

    fill_in 'Name', with: 'My New Team'
    fill_in 'Short name', with: 'MNT'

    click_button 'Create'
    expect(page).to have_content 'Created successfully'
    expect(page).to have_content 'My New Team'
    expect(page).to have_content "Owner: #{@member.first_name} #{@member.last_name}"
  end

  scenario 'cannot create a team in a league if they already have one' do
    league = create(:football_league)
    create(:team, league: league, user: @member)
    navigate_to_league

    expect(page).to have_no_link 'New Team'
  end
end
