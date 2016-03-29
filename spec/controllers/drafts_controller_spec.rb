require 'rails_helper'

describe DraftsController do
  context '#show' do
    before do
      sign_in create(:user)
    end

    it 'begins the draft if not yet started' do
      @league = create(:football_league, :with_draft_not_started)

      expect(@league.draft_status.description).to eq 'Not Started'
    end

    it 'does nothing if the draft has already started' do
      @league = create(:football_league, :with_draft_in_progress)

      expect(@league.draft_status.description).to eq 'In Progress'
    end

    after do
      get :show, params: { league_id: @league.id }
      expect(League.find(@league.id).draft_status.description).to eq 'In Progress'
    end
  end
end
