require 'spec_helper'

feature 'Teams' do
  before do
    @first_owner = create(:user)
    @league = create(:league, user_id: @first_owner.id)
    sign_in @first_owner
  end

  scenario 'can be created within a league' do
    navigate_to_league('Fantasy Sports Dojo')
    click_link 'New Team'

    fill_in 'Name', with: 'My New Team'
    fill_in 'Short name', with: 'MNT'

    click_button 'Create'
    expect(page).to have_content 'Created successfully'
    expect(page).to have_content 'My New Team'
    expect(page).to have_content "Owner: #{ @first_owner.first_name } #{ @first_owner.last_name }"
  end

  scenario 'cannot create another team if they already have one' do
    create(:team, league_id: @league.id, user_id: @first_owner.id)
    navigate_to_league('Fantasy Sports Dojo')

    expect(page).to have_no_link 'New Team'
  end

  scenario 'cannot create another team once the league is full' do
    @league.size.times do
      owner = create(:user)
      create(:team, league_id: @league.id, user_id: owner.id)
    end

    navigate_to_league('Fantasy Sports Dojo')
    expect(page).to have_no_link 'New Team'
  end

  scenario 'can view a list of teams' do
    @first_owner_team = create(:team, league_id: @league.id,  user_id: @first_owner.id)
    @second_owner = create(:user)
    @second_owner_team = create(:team, league_id: @league.id,  user_id: @second_owner.id)

    navigate_to_league('Fantasy Sports Dojo')
    click_link 'Teams'
    expect(page).to have_content @first_owner_team.name
    expect(page).to have_content @second_owner_team.name
  end
end
