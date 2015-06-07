require 'spec_helper'

describe DraftStatus do
  it { should validate_presence_of(:description) }
  it { should validate_uniqueness_of(:description) }
end
