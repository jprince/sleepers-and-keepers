require 'rails_helper'

describe Pick do
  it { should validate_presence_of(:overall_pick) }
  it { should validate_presence_of(:round) }
  it { should validate_presence_of(:round_pick) }

  it { should belong_to(:player) }
  it { should belong_to(:team) }
  it { should have_one(:league) }

  describe '#last_pick_of_draft?' do
    before do
      league = create(:football_league, :with_draft_in_progress)
      team = create(:team, league: league)
      @pick = create(:pick, team: team)
    end

    it 'returns true if it is last pick in draft' do
      expect(@pick.last_pick_of_draft?).to be_truthy
    end

    it 'returns false if there are picks remaining' do
      create(:pick, team: @team)
      expect(@pick.last_pick_of_draft?).to be_falsy
    end
  end

  describe '#previous' do
    before do
      @league = create(:football_league, :with_draft_in_progress)
      @team = create(:team, league: @league)
      @pick = create(:pick, team: @team)
    end

    it 'returns the previous pick, if it exists' do
      pick = create(:pick, team: @team)
      expect(pick.previous).to eq @pick
    end

    it 'skips keepers' do
      player = create(:player, sport: @league.sport)
      create(:pick, keeper: true, player: player, team: @team)
      pick = create(:pick, team: @team)
      expect(pick.previous).to eq @pick
    end

    it 'returns nil if there is no previous pick' do
      expect(@pick.previous).to be_nil
    end
  end

  describe '.create_picks' do
    before do
      @league = create(:football_league, rounds: 16)
    end

    it 'generates the draft picks for a league' do
      total_picks = @league.size * @league.rounds
      @league.size.times do
        create(:team, league: @league)
      end
      expect(Pick.all).to be_empty

      Pick.create_picks(@league)
      expect(Pick.all.length).to eq total_picks

      first_overall_pick = Pick.first
      team_with_first_pick = Team.find_by(draft_pick: 1)
      expect(first_overall_pick.round).to eq 1
      expect(first_overall_pick.round_pick).to eq 1
      expect(first_overall_pick.overall_pick).to eq 1
      expect(first_overall_pick.team.id).to eq team_with_first_pick.id
      expect(team_with_first_pick.picks.length).to eq @league.rounds

      first_pick_of_second_round = Pick.find_by(overall_pick: @league.size + 1)
      expect(first_pick_of_second_round.team.id).to eq Team.find_by(draft_pick: @league.size).id

      last_overall_pick = Pick.last
      expect(last_overall_pick.round).to eq @league.rounds
      expect(last_overall_pick.round_pick).to eq @league.size
      expect(last_overall_pick.overall_pick).to eq total_picks
      expect(last_overall_pick.team.id).to eq team_with_first_pick.id
    end

    it "calls 'remove_picks' for the league" do
      expect(Pick).to receive(:remove_picks).with(@league)
      Pick.create_picks(@league)
    end
  end

  describe '.remove_picks' do
    it 'clears any existing picks' do
      league = create(:football_league)
      league.size.times do
        create(:team, league: league)
      end
      total_picks = league.size * league.rounds

      2.times do
        Pick.create_picks(league)
        expect(Pick.all.length).to eq total_picks
      end
    end
  end
end
