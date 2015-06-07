require 'spec_helper'

describe League do
  it { should validate_presence_of(:draft_status_id) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:password) }
  it { should validate_presence_of(:size) }
  it { should validate_presence_of(:rounds) }

  it { should belong_to(:draft_status) }
  it { should belong_to(:sport) }
  it { should belong_to(:user) }
  it { should have_many(:teams) }
end
