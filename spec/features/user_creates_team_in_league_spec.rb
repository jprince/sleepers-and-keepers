require 'spec_helper'

feature 'Teams' do
  before do
    @first_owner = create(:user)
    @league = create(:football_league, user: @first_owner)
    sign_in @first_owner
  end

  scenario 'can be created within a league' do
    navigate_to_league
    click_link 'New Team'

    fill_in 'Name', with: 'My New Team'
    fill_in 'Short name', with: 'MNT'

    click_button 'Create'
    expect(page).to have_content 'Created successfully'
    expect(page).to have_content 'My New Team'
    expect(page).to have_content "Owner: #{ @first_owner.first_name } #{ @first_owner.last_name }"
  end

  scenario 'cannot create another team if they already have one' do
    create(:team, league: @league, user: @first_owner)
    navigate_to_league

    expect(page).to have_no_link 'New Team'
  end

  scenario 'cannot create another team once the league is full' do
    fill_league @league
    navigate_to_league
    expect(page).to have_no_link 'New Team'
  end

  scenario 'can view a list of teams' do
    @first_owner_team = create(:team, league: @league,  user: @first_owner)
    @second_owner = create(:user)
    @second_owner_team = create(:team, league: @league,  user: @second_owner)

    navigate_to_league
    click_link 'Teams'
    expect(page).to have_content @first_owner_team.name
    expect(page).to have_content @second_owner_team.name
  end
end
