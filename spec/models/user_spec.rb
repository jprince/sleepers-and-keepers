require 'spec_helper'

describe User do
  it { should validate_presence_of(:first_name) }
  it { should validate_presence_of(:last_name) }
  it { should have_many(:teams) }

  it 'can be created with name, email address and password' do
    user = create(:user)
    expect(user).to be_valid
  end

  it 'requires a password of eight or more characters' do
    invalid_user = build(:user, password: '1234567')
    expect(invalid_user).not_to be_valid
    expect(password_validation_errors(invalid_user)).to include 'is too short'
  end

  it 'validates the format of email addresses' do
    invalid_user = build(:user, email: 'user_at_example.com')
    expect(invalid_user).not_to be_valid
    expect(email_validation_errors(invalid_user)).to include 'Invalid email address'
  end

  def email_validation_errors(user)
    user.errors.messages[:email].join(' ')
  end

  def password_validation_errors(user)
    user.errors.messages[:password].join(' ')
  end
end
