require 'rails_helper'

describe League do
  it { should validate_presence_of(:draft_status_id) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:size) }
  it { should validate_presence_of(:rounds) }

  it { should belong_to(:draft_status) }
  it { should belong_to(:sport) }
  it { should belong_to(:user) }
  it { should have_many(:picks) }
  it { should have_many(:teams) }

  describe '.update_draft_status' do
    it 'starts the draft if it has not been started yet' do
      league = create(:football_league)
      expect(league.draft_status_id).to eq DraftStatus.find_by(description: 'Not Started').id

      league.update_draft_status
      expect(League.last.draft_status_id).to eq DraftStatus.find_by(description: 'In Progress').id
    end

    it 'completes the draft after all picks have been made' do
      league = create(:football_league, :with_draft_in_progress)
      expect(league.draft_status_id).to eq DraftStatus.find_by(description: 'In Progress').id

      league.update_draft_status
      expect(League.last.draft_status_id).to eq DraftStatus.find_by(description: 'Complete').id
    end

    it 'will undo completion if there are picks to be made' do
      league = create(:football_league, :with_draft_complete)
      team = create(:team, league: league)
      create(:pick, player: nil, team: team)
      expect(league.draft_status_id).to eq DraftStatus.find_by(description: 'Complete').id

      league.update_draft_status
      expect(League.last.draft_status_id).to eq DraftStatus.find_by(description: 'In Progress').id
    end
  end
end
