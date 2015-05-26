require 'spec_helper'

feature 'League creator' do
  before do
    create(:sport)
    sign_in create(:user)
  end

  scenario 'can set draft order' do
    create(:league)
    create(:team)
    11.times do
      owner = create(:user)
      create(:team, user_id: owner.id)
    end
    navigate_to_league('Fantasy Sports Dojo')

    click_link 'Set draft order'

    fill_in 'teams[1][draft_pick]', with: 10
    fill_in 'teams[3][draft_pick]', with: 12
    click_button 'Save'

    expect(page).to have_revised_draft_order
  end
end

feature 'League member' do
  before do
    create(:sport)
    create(:user)
    create(:league)
    league_member = create(:user)
    sign_in league_member
    create(:team, user_id: league_member.id)
    navigate_to_league('Fantasy Sports Dojo')
  end

  scenario 'cannot set draft order' do
    expect(page).to have_no_content 'Set draft order'
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
