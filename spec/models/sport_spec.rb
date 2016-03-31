require 'rails_helper'

describe Sport do
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }

  it { should have_many(:leagues) }
  it { should have_many(:players) }
end

describe Sport, '#position_options' do
  it 'returns positions for baseball' do
    baseball = Sport.find_by(name: 'Baseball')
    expect(baseball.position_options).to eq %w(ALL C 1B 2B 3B SS OF SP RP DH)
  end

  it 'returns positions for football' do
    football = Sport.find_by(name: 'Football')
    expect(football.position_options).to eq %w(ALL QB RB WR TE K DST)
  end
end

describe Sport, '.seed' do
  before do
    Sport.destroy_all
  end

  it 'inserts new sports' do
    sports = Sport.all
    expect(sports).to be_empty

    Sport.seed
    sports = Sport.all
    expect(sports.length).to eq 2
  end

  it 'does not update existing sports' do
    sport = create(:sport, name: 'Football', positions: [])

    Sport.seed
    expect(Sport.find_by(name: sport.name).position_options).to eq sport.position_options
  end
end
