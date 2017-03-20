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

  describe '#begin_draft' do
    it "sets draft status 'in progress' if it hasn't started yet" do
      league = create(:football_league, :with_draft_not_started)
      expect(league.draft_status.description).to eq 'Not Started'

      league.begin_draft
      expect(league.draft_status.description).to eq 'In Progress'
    end
  end

  describe '#complete_draft' do
    it "sets draft status 'in progress' if it hasn't completed yet" do
      league = create(:football_league, :with_draft_in_progress)
      expect(league.draft_status.description).to eq 'In Progress'

      league.complete_draft
      expect(league.draft_status.description).to eq 'Complete'
    end
  end

  describe '#current_pick' do
    it "returns the current pick for the selected league's draft" do
      league = create(:football_league)
      team_with_first_pick = create(:team, league: league)
      first_pick = create(:pick, team: team_with_first_pick)
      team_with_second_pick = create(:team, league: league)
      keeper = create(:player, sport: league.sport)
      create(:pick, keeper: true, player: keeper, team: team_with_second_pick)
      team_with_third_pick = create(:team, league: league)
      third_pick = create(:pick, team: team_with_third_pick)

      expect(league.current_pick).to eq first_pick

      first_pick.player = create(:player, sport: league.sport)
      first_pick.save!

      expect(league.current_pick).to eq third_pick
    end
  end

  describe '#draft_not_started?' do
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

  describe '#draft_state' do
    it 'returns pertinent draft information' do
      league = create(:football_league)
      team_with_first_pick = create(:team, league: league)
      team_with_second_pick = create(:team, league: league)
      first_pick = create(:pick, team: team_with_first_pick)
      create(:pick, team: team_with_second_pick)

      expect(league.draft_state[:current_pick]).to eq(
        'id' => first_pick.id,
        'overall_pick' => first_pick.overall_pick,
        'round' => first_pick.round,
        'round_pick' => first_pick.round_pick,
        'team_id' => first_pick.team_id
      )
      expect(league.draft_state[:last_selected_player]).to be_nil
      expect(league.draft_state[:league_id]).to eq league.id
      expect(league.draft_state[:draft_status]).to eq 'Not Started'

      selected_player = create(:player, sport: league.sport)
      first_pick.player = selected_player
      first_pick.save!

      expect(league.draft_state[:last_selected_player]).to eq(
        'id' => selected_player.id,
        'first_name' => selected_player.first_name,
        'last_name' => selected_player.last_name,
        'name' => "#{selected_player.last_name}, #{selected_player.first_name}",
        'position' => selected_player.position,
        'photo_url' => selected_player.photo_url,
        'team' => selected_player.team,
        'injury' => selected_player.injury,
        'headline' => selected_player.headline
      )
    end
  end
end
