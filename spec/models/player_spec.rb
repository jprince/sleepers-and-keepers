require 'rails_helper'

describe Player do
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:orig_id) }
  it { should validate_presence_of(:position) }
  it { should validate_presence_of(:team) }

  it { should belong_to(:sport) }
  it { should have_many(:teams) }
end

describe Player do
  context 'All sports' do
    before do
      allow(STDOUT).to receive(:write)
      @football = Sport.find_by(name: 'Football')
    end

    describe '.update_player_pool' do
      before do
        player_data = mock_player_data('QB')
        allow(CBSSportsAPI).to receive(:new).and_return(player_data)
      end

      it 'inserts new players' do
        expect(Player.where(deleted_at: nil)).to be_empty

        Player.update_player_pool
      end

      it 'updates existing players' do
        create(:player, sport: @football)

        expect(Player.where(deleted_at: nil).count).to eq 1

        Player.update_player_pool
      end

      it 'marks old players as deleted' do
        old_player =
          create(:player, sport: @football, first_name: 'Josh', last_name: 'Prince', orig_id: '-1')

        expect(Player.where(deleted_at: nil).count).to eq 1

        Player.update_player_pool

        expect(old_player.reload.deleted_at).to be_truthy
      end

      after do
        expect(Player.where(deleted_at: nil).count).to eq 1

        player = Player.last
        expect(player.first_name).to eq 'Tom'
        expect(player.last_name).to eq 'Brady'
        expect(player.position).to eq 'QB'
        expect(player.team).to eq 'NE'
        expect(player.headline).to eq 'Brady wins Super Bowl MVP'
        expect(player.injury).to be_nil
        expect(player.photo_url).to eq(
          'http://sports.cbsimg.net/images/blogs/Tom-brady.turkey.400.jpg'
        )
        expect(player.pro_status).to eq 'A'
        expect(player.sport_id).to eq @football.id.to_s
        expect(player.orig_id).to eq '1'
      end
    end

    describe '.undrafted' do
      it 'returns only undrafted players for a league' do
        create(:player, last_name: 'undrafted', sport: @football)
        drafted_player = create(:player, last_name: 'drafted', sport: @football)
        league = create(:league, sport: @football)
        team = create(:team, league: league)

        expect(Player.undrafted(League.last).count).to eq 2
        create(:pick, player: drafted_player, team: team)
        expect(Player.undrafted(League.last).count).to eq 1
      end

      it 'does not return deleted players' do
        create(:player, last_name: 'undrafted', sport: @football)
        create(:player, last_name: 'deleted', sport: @football, deleted_at: Time.zone.now)

        league = create(:league, sport: @football)
        undrafted_players = Player.undrafted(league)
        expect(undrafted_players.count).to eq 1
        expect(undrafted_players.first.last_name).to eq 'undrafted'
      end
    end
  end

  context 'Baseball' do
    it 'normalizes outfield positions' do
      allow(STDOUT).to receive(:write)

      %w(CF LF OF RF).all? do |pos|
        player_data = mock_player_data(pos)
        allow(CBSSportsAPI).to receive(:new).and_return(player_data)
        Player.update_player_pool
        expect(Player.last.position).to eq 'OF'
      end
    end
  end
end

def mock_player_data(position)
  Struct.new(:players).new(
    "{
      \"body\":{
        \"players\":
          [
            {
              \"firstname\":\"Tom\",
              \"lastname\":\"Brady\",
              \"position\":\"#{position}\",
              \"pro_team\":\"NE\",
              \"icons\": {
                \"headline\":\"Brady wins Super Bowl MVP\"
                },
              \"photo\":\"http://sports.cbsimg.net/images/blogs/Tom-brady.turkey.400.jpg\",
              \"pro_status\":\"A\",
              \"id\":\"1\"
            }
          ]
        }
    }"
  )
end
