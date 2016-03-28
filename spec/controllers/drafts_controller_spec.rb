require 'rails_helper'

describe DraftsController do
  context '#show' do
    before do
      sign_in create(:user)
    end

    it 'begins the draft if not yet started' do
      league = create(:football_league, :with_draft_not_started)

      expect(league.draft_status.description).to eq 'Not Started'
      get :show, league_id: league.id
      league.reload
      expect(league.draft_status.description).to eq 'In Progress'
    end

    it 'does nothing if the draft has already started' do
      league = create(:football_league, :with_draft_in_progress)

      expect(league.draft_status.description).to eq 'In Progress'
      get :show, league_id: league.id
      league.reload
      expect(league.draft_status.description).to eq 'In Progress'
    end
  end
end
