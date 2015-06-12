require 'spec_helper'

feature 'League creator' do
  before do
    @creator = create(:user)
    sign_in @creator
  end

  scenario 'can set draft order' do
    league = create(:football_league, user: @creator)
    create(:team, league: league)
    11.times do
      owner = create(:user)
      create(:team, league: league, user: owner)
    end

    navigate_to_league
    click_link 'Set draft order'

    fill_in 'teams[1][draft_pick]', with: 10
    fill_in 'teams[3][draft_pick]', with: 12
    click_button 'Save'

    expect(page).to have_revised_draft_order
  end

  scenario 'can start the draft when the league is full' do
    create(:draft_status, description: 'In Progress')
    league = create(:football_league, user: @creator)

    navigate_to_league
    expect(page).to have_no_link 'Start draft'
    fill_league league

    visit current_path
    click_link 'Start draft'
    expect(page).to have_content 'Fantasy Sports Dojo Draft'
  end

  scenario 'can join a draft in progress' do
    create(:football_league, :with_draft_in_progress, user: @creator)

    navigate_to_league
    expect(page).to have_link 'Join draft'
  end

  scenario 'cannot start or join a completed draft' do
    create(:football_league, :with_draft_complete, user: @creator)

    navigate_to_league
    expect(page).to have_no_link 'Start draft'
    expect(page).to have_no_link 'Join draft'
  end
end

feature 'League member' do
  scenario 'cannot set draft order' do
    create_and_sign_in_league_member_with_draft('not started')
    navigate_to_league
    expect(page).to have_no_link 'Set draft order'
  end

  scenario 'cannot start the draft' do
    create_and_sign_in_league_member_with_draft('not started')
    navigate_to_league
    expect(page).to have_no_link 'Start draft'
  end

  scenario 'can join a draft in progress' do
    create_and_sign_in_league_member_with_draft('in progress')
    navigate_to_league
    expect(page).to have_link 'Join draft'
  end

  scenario 'cannot join a completed draft' do
    create_and_sign_in_league_member_with_draft('complete')
    navigate_to_league
    expect(page).to have_no_link 'Join draft'
  end
end

def create_and_sign_in_league_member_with_draft(draft_status)
  factory_trait =
    case draft_status
    when 'in progress'
      :with_draft_in_progress
    when 'complete'
      :with_draft_complete
    else
      nil
    end
  league = create(:football_league, factory_trait)
  league_member = create(:user)
  create(:team, league: league, user: league_member)
  sign_in league_member
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
