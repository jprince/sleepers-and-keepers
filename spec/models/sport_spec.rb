require 'spec_helper'

describe Sport do
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
  it { should have_many(:leagues) }
end

describe Sport, '.seed' do
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
    expect(Sport.find_by_name(sport.name).positions).to eq sport.positions
  end
end
