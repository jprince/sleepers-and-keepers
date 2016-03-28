require 'rails_helper'

describe DraftPicksController do
  context '#create' do
    before do
      sign_in create(:user)
    end

    before do
      @league = create(:football_league, :with_draft_in_progress)
      @team = create(:team, league: @league)
      @pick = create(:pick, team: @team)
      @player = create(:player, sport: @league.sport)

      expect(@league.draft_status.description).to eq 'In Progress'
    end

    it 'completes the draft if no picks remain' do
      post :create, league_id: @league.id, pick: {
        pick_id: @pick.id,
        player_id: @player.id
      }
      @league.reload
      expect(@league.draft_status.description).to eq 'Complete'
    end

    it 'does not complete the draft if additional picks remain' do
      @future_pick = create(:pick, team: @team)

      post :create, league_id: @league.id, pick: {
        pick_id: @pick.id,
        player_id: @player.id
      }
      @league.reload
      expect(@league.draft_status.description).to eq 'In Progress'
    end
  end

  context '#update' do
    before do
      sign_in create(:user)
    end

    it "sets draft status to 'in progress' if the last pick is undone" do
      league = create(:football_league, :with_draft_complete)
      team = create(:team, league: league)
      player = create(:player, sport: league.sport)
      create(:pick, player: player, team: team)

      expect(league.draft_status.description).to eq 'Complete'

      post :update, league_id: league.id
      league.reload
      expect(league.draft_status.description).to eq 'In Progress'
    end

    it "does not set draft status to 'in progress' if any pick other than the last is undone" do
      league = create(:football_league, :with_draft_in_progress)
      team = create(:team, league: league)
      player = create(:player, sport: league.sport)
      create(:pick, player: player, team: team)
      create(:pick, team: @team)

      expect(league.draft_status.description).to eq 'In Progress'

      post :update, league_id: league.id
      league.reload
      expect(league.draft_status.description).to eq 'In Progress'
    end
  end
end
