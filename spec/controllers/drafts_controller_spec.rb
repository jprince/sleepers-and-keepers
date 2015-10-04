require 'spec_helper'

describe DraftsController do
  describe '#show' do
    context 'instance variables' do
      before do
        @current_league = create(:football_league)
        other_league = create(:football_league)
        @current_league_team = create(:team, league: @current_league)
        @other_league_team = create(:team, league: other_league)
      end

      it 'get teams only for the current_league' do
        get :show, league_id: @current_league.id
        assigns(:teams).should == [@current_league_team]
      end

      it 'get picks only for the current league' do
        current_league_pick = create(:pick, team: @current_league_team)
        create(:pick, team: @other_league_team)

        get :show, league_id: @current_league.id
        assigns(:picks).should == [current_league_pick]
      end
    end

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
