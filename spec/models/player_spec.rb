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
    end

    let(:football) { Sport.find_by(name: 'Football') }

    describe '#name' do
      it "formats as 'last_name, first_name'" do
        player = create(:player, first_name: 'Josh', last_name: 'Prince', sport: football)
        expect(player.name).to eq 'Prince, Josh'
      end

      it "returns the last_name if the player's first_name is blank" do
        player = create(:player, first_name: nil, last_name: 'Patriots', sport: football)
        expect(player.name).to eq 'Patriots'
      end
    end

    describe '.update_player_pool' do
      let(:player_data) { mock_player_data('QB') }

      before do
        allow(CBSSportsAPI).to receive(:new).and_return(player_data)
      end

      context 'inserts/updates' do
        let(:player) { Player.last }

        it 'inserts new players' do
          expect(Player.all).to be_empty
          Player.update_player_pool
          expect(Player.all.length).to eq 1
        end

        it 'updates existing players' do
          create(:player, orig_id: '1', sport: football)
          expect(Player.all.length).to eq 1
          Player.update_player_pool
        end

        after do
          expect(player).to have_attributes(
            first_name: 'Tom',
            last_name: 'Brady',
            position: 'QB',
            team: 'NE',
            headline: 'Brady wins Super Bowl MVP... again',
            injury: nil,
            photo_url: 'http://sports.cbsimg.net/images/blogs/Tom-brady.turkey.400.jpg',
            pro_status: 'A',
            sport_id: football.id.to_s,
            orig_id: '1'
          )
        end
      end

      it 'marks players as deleted' do
        create(:player, sport: football, orig_id: '-1')

        expect(Player.all.length).to eq 1
        expect(Player.deleted.length).to eq 0

        Player.update_player_pool

        expect(Player.all.length).to eq 1
        expect(Player.deleted.length).to eq 1
      end

      it 'restores previously deleted players' do
        create(:player, sport: football, deleted_at: Time.zone.now, orig_id: '1')

        expect(Player.all.length).to eq 0
        expect(Player.deleted.length).to eq 1

        Player.update_player_pool

        expect(Player.all.length).to eq 1
        expect(Player.deleted.length).to eq 0
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
                \"headline\":\"Brady wins Super Bowl MVP... again\"
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
