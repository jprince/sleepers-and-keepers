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

  describe '.begin_draft' do
    before do
      @league = create(:football_league, :with_draft_not_started)
      expect(@league.draft_status.description).to eq 'Not Started'
    end

    it "sets draft status 'in progress' if it hasn't started yet" do
      @league.begin_draft
      expect(@league.draft_status.description).to eq 'In Progress'
    end
  end

  describe '.complete_draft' do
    before do
      @league = create(:football_league, :with_draft_in_progress)
      expect(@league.draft_status.description).to eq 'In Progress'
    end

    it "sets draft status 'in progress' if it hasn't started yet" do
      @league.complete_draft
      expect(@league.draft_status.description).to eq 'Complete'
    end
  end

  describe '.current_pick' do
    it "returns the current pick for the selected league's draft" do
      league = create(:football_league)
      team_with_first_pick = create(:team, league: league)
      team_with_second_pick = create(:team, league: league)
      first_pick = create(:pick, team: team_with_first_pick)
      second_pick = create(:pick, team: team_with_second_pick)

      expect(league.current_pick.id).to eq first_pick.id

      first_pick.player = create(:player, sport: league.sport)
      first_pick.save!

      expect(league.current_pick.id).to eq second_pick.id
    end
  end

  describe '.draft_not_started?' do
    it 'returns true if the draft has not started' do
      league = create(:football_league, :with_draft_not_started)
      expect(league.draft_not_started?).to be_truthy
    end

    it 'returns false if the draft is in progress' do
      league = create(:football_league, :with_draft_in_progress)
      expect(league.draft_not_started?).to be_falsy
    end

    it 'returns false if the draft is complete' do
      league = create(:football_league, :with_draft_complete)
      expect(league.draft_not_started?).to be_falsy
    end
  end
end
