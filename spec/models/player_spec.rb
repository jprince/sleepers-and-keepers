require 'spec_helper'

describe Player do
  it { should validate_presence_of(:last_name) }
  it { should validate_presence_of(:orig_id) }
  it { should validate_presence_of(:position) }
  it { should validate_presence_of(:team) }

  it { should belong_to(:sport) }
end

describe Player do
  before do
    @sport = create(:sport)
    player_data = "{
      \"body\":{
        \"players\":
          [
            {
              \"firstname\":\"Tom\",
              \"lastname\":\"Brady\",
              \"position\":\"QB\",
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
    CBSSportsAPI.any_instance.stub(players: player_data)
    STDOUT.stub(:write)
  end

  describe '.update_player_pool' do
    it 'inserts new players' do
      expect(Player.all).to be_empty

      Player.update_player_pool

      expect(Player.all.length).to eq 1
    end

    it 'updates existing players' do
      create(:player, sport: @sport)

      expect(Player.all.length).to eq 1

      Player.update_player_pool
    end
  end

  after do
    player = Player.last
    expect(player.first_name).to eq 'Tom'
    expect(player.last_name).to eq 'Brady'
    expect(player.position).to eq 'QB'
    expect(player.team).to eq 'NE'
    expect(player.headline).to eq 'Brady wins Super Bowl MVP'
    expect(player.injury).to be_nil
    expect(player.photo_url).to eq 'http://sports.cbsimg.net/images/blogs/Tom-brady.turkey.400.jpg'
    expect(player.pro_status).to eq 'A'
    expect(player.sport_id).to eq '1'
    expect(player.orig_id).to eq '1'
  end
end
