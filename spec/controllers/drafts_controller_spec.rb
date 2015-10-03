require 'spec_helper'

describe DraftsController do
  describe '#show' do
    it 'starts the draft if it has not been started yet' do
      league = create(:football_league)
      expect(league.draft_status_id).to eq DraftStatus.find_by(description: 'Not Started').id

      get :show, league_id: league.id
      expect(League.last.draft_status_id).to eq DraftStatus.find_by(description: 'In Progress').id
    end

    it 'completes the draft after all picks have been made' do
      league = create(:football_league, :with_draft_in_progress)
      expect(league.draft_status_id).to eq DraftStatus.find_by(description: 'In Progress').id

      get :show, league_id: league.id
      expect(League.last.draft_status_id).to eq DraftStatus.find_by(description: 'Complete').id
    end

    it 'will undo completion if there are picks to be made' do
      league = create(:football_league, :with_draft_complete)
      team = create(:team, league: league)
      create(:pick, player: nil, team: team)
      expect(league.draft_status_id).to eq DraftStatus.find_by(description: 'Complete').id

      get :show, league_id: league.id
      expect(League.last.draft_status_id).to eq DraftStatus.find_by(description: 'In Progress').id
    end
  end
end
