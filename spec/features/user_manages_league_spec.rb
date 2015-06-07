require 'spec_helper'

feature 'League creator' do
  before do
    @creator = create(:user)
    sign_in @creator
  end

  scenario 'can set draft order' do
    league = create(:league, user_id: @creator.id)
    create(:team, league_id: league.id)
    11.times do
      owner = create(:user)
      create(:team, league_id: league.id, user_id: owner.id)
    end

    navigate_to_league('Fantasy Sports Dojo')
    click_link 'Set draft order'

    fill_in 'teams[1][draft_pick]', with: 10
    fill_in 'teams[3][draft_pick]', with: 12
    click_button 'Save'

    expect(page).to have_revised_draft_order
  end

  scenario 'can start the draft' do
    create(:draft_status, description: 'In Progress')
    create(:league, user_id: @creator.id)

    navigate_to_league('Fantasy Sports Dojo')

    click_link 'Start draft'
    expect(page).to have_content 'Fantasy Sports Dojo Draft'
  end

  scenario 'can join a draft in progress' do
    in_progress_status = create(:draft_status, description: 'In Progress')
    create(:league, user_id: @creator.id, draft_status_id: in_progress_status.id)

    navigate_to_league('Fantasy Sports Dojo')
    expect(page).to have_link 'Join draft'
  end

  scenario 'cannot start or join a completed draft' do
    completed_status = create(:draft_status, description: 'Complete')
    create(:league, user_id: @creator.id, draft_status_id: completed_status.id)

    navigate_to_league('Fantasy Sports Dojo')
    expect(page).to have_no_link 'Start draft'
    expect(page).to have_no_link 'Join draft'
  end
end

feature 'League member' do
  before do
    draft_status = create(:draft_status, description: 'In Progress')
    @league = create(:league, draft_status_id: draft_status.id)
    league_member = create(:user)
    create(:team, league_id: @league.id, user_id: league_member.id)
    sign_in league_member
  end

  scenario 'cannot set draft order' do
    navigate_to_league('Fantasy Sports Dojo')
    expect(page).to have_no_link 'Set draft order'
  end

  scenario 'cannot start the draft' do
    navigate_to_league('Fantasy Sports Dojo')
    expect(page).to have_no_link 'Start draft'
  end

  scenario 'can join a draft in progress' do
    navigate_to_league('Fantasy Sports Dojo')
    expect(page).to have_link 'Join draft'
  end

  scenario 'cannot join a completed draft' do
    completed_draft_status = create(:draft_status, description: 'Complete')
    @league.draft_status_id = completed_draft_status.id
    @league.save
    navigate_to_league('Fantasy Sports Dojo')
    expect(page).to have_no_link 'Join draft'
  end
end

def has_revised_draft_order?
  team_one_pick = find('input#team-1')
  team_three_pick = find('input#team-3')

  teams_have_correct_draft_picks_set =
    team_one_pick.value == '10' &&
    team_three_pick.value == '12'

  draft_order_inputs = all('#draft-order input')
  teams_in_correct_order =
    draft_order_inputs[9] == team_one_pick &&
    draft_order_inputs[11] == team_three_pick

  teams_have_correct_draft_picks_set && teams_in_correct_order
end
