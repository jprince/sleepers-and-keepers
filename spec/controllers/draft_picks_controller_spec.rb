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

    it 'assigns a player to the draft pick' do
      post :create, params: {
        league_id: @league.id,
        pick: {
          pick_id: @pick.id,
          player_id: @player.id
        }
      }
      expect(Pick.find(@pick.id).player).to eq @player
    end

    it 'renders the draft state' do
      create(:pick, team: @team)
      post :create, params: {
        league_id: @league.id,
        pick: {
          pick_id: @pick.id,
          player_id: @player.id
        }
      }
      expect(@response.body).to eq @league.draft_state.camelize.to_json
    end

    it 'completes the draft if no picks remain' do
      post :create, params: {
        league_id: @league.id,
        pick: {
          pick_id: @pick.id,
          player_id: @player.id
        }
      }
      expect(League.find(@league.id).draft_status.description).to eq 'Complete'
    end

    it 'does not complete the draft if additional picks remain' do
      create(:pick, team: @team)
      post :create, params: {
        league_id: @league.id,
        pick: {
          pick_id: @pick.id,
          player_id: @player.id
        }
      }
      expect(League.find(@league.id).draft_status.description).to eq 'In Progress'
    end
  end

  context '#update' do
    before do
      sign_in create(:user)
    end

    it 'clears the player from the last draft pick' do
      league = create(:football_league, :with_draft_in_progress)
      team = create(:team, league: league)
      player = create(:player, sport: league.sport)
      pick = create(:pick, player: player, team: team)

      post :update, params: { league_id: league.id }
      expect(Pick.find(pick.id).player).to be_nil
    end

    it 'renders the draft state (with some additional data)' do
      league = create(:football_league, :with_draft_in_progress)
      team = create(:team, league: league)
      player = create(:player, sport: league.sport)
      create(:pick, player: player, team: team)

      post :update, params: { league_id: league.id }

      draft_state = league.draft_state.merge(
        is_undo: true,
        last_selected_player: {
          id: player.id,
          first_name: player.first_name,
          last_name: player.last_name,
          position: player.position,
          team: player.team,
          injury: player.injury,
          headline: player.headline
        }
      )
      expect(@response.body).to eq draft_state.camelize.to_json
    end

    it 'does not undo keepers' do
      league = create(:football_league, :with_draft_in_progress)
      team = create(:team, league: league)
      player_one = create(:player, sport: league.sport)
      player_two = create(:player, sport: league.sport)
      pick = create(:pick, player: player_one, team: team)
      keeper = create(:pick, player: player_two, team: team, keeper: true)

      post :update, params: { league_id: league.id }
      expect(Pick.find(keeper.id).player).to eq player_two
      expect(Pick.find(pick.id).player).to be_nil
    end

    it "sets draft status to 'in progress' if the last pick is undone" do
      league = create(:football_league, :with_draft_complete)
      team = create(:team, league: league)
      player = create(:player, sport: league.sport)
      create(:pick, player: player, team: team)

      expect(league.draft_status.description).to eq 'Complete'

      post :update, params: { league_id: league.id }
      expect(League.find(league.id).draft_status.description).to eq 'In Progress'
    end

    it 'does not change draft status if any pick other than the last is undone' do
      league = create(:football_league, :with_draft_in_progress)
      team = create(:team, league: league)
      player = create(:player, sport: league.sport)
      create(:pick, player: player, team: team)
      create(:pick, team: @team)

      expect(league.draft_status.description).to eq 'In Progress'

      post :update, params: { league_id: league.id }
      expect(League.find(league.id).draft_status.description).to eq 'In Progress'
    end
  end
end
