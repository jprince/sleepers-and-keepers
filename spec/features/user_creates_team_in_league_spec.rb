require 'spec_helper'

feature 'Teams' do
  before do
    @member = create(:user)
    sign_in @member
  end

  scenario 'can be created within a league' do
    create(:football_league)
    navigate_to_league
    click_link 'New Team'

    fill_in 'Name', with: 'My New Team'
    fill_in 'Short name', with: 'MNT'

    click_button 'Create'
    expect(page).to have_content 'Created successfully'
    expect(page).to have_content 'My New Team'
    expect(page).to have_content "Owner: #{ @member.first_name } #{ @member.last_name }"
  end

  scenario 'cannot create another team if they already have one' do
    league = create(:football_league)
    create(:team, league: league, user: @member)
    navigate_to_league

    expect(page).to have_no_link 'New Team'
  end

  scenario 'cannot create a team once the league is full' do
    league = create(:football_league)
    fill_league league
    navigate_to_league
    expect(page).to have_no_link 'New Team'
  end

  scenario 'can view a list of teams' do
    league = create(:football_league)
    @member_team = create(:team, league: league,  user: @member)
    @second_member = create(:user)
    @second_member_team = create(:team, league: league,  user: @second_member)

    navigate_to_league
    click_link 'Teams'
    expect(page).to have_content @member_team.name
    expect(page).to have_content @second_member_team.name
  end

  scenario 'can join a draft in progress' do
    league = create(:football_league, :with_draft_in_progress)
    create(:team, league: league, user: @member)

    navigate_to_league
    expect(page).to have_link 'Join draft'
  end

  scenario 'cannot join a completed draft' do
    league = create(:football_league, :with_draft_complete)
    create(:team, league: league, user: @member)

    navigate_to_league
    expect(page).to have_no_link 'Join draft'
  end
end
