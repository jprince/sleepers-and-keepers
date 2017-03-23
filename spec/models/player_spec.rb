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
      before do
        player_data = mock_player_data('QB')
        allow(CBSSportsAPI).to receive(:new).and_return(player_data)
      end

      it 'inserts new players' do
        expect(Player.all).to be_empty

        Player.update_player_pool

        expect(Player.all.length).to eq 1
      end

      it 'updates existing players' do
        create(:player, sport: football)

        expect(Player.all.length).to eq 1

        Player.update_player_pool
      end

      after do
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
        expect(player.sport_id).to eq football.id.to_s
        expect(player.orig_id).to eq '1'
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
