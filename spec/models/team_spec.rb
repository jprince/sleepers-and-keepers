require 'spec_helper'

describe Team do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:short_name) }
  it { should ensure_length_of(:short_name).is_at_most(10) }

  it { should belong_to(:league) }
  it { should have_many(:picks) }
  it { should have_many(:players) }
end
