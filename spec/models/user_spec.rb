require 'spec_helper'

describe User do
  it 'can be created with an email address and password' do
    user = create(:user)
    expect(user).to be_valid
  end

  context 'password' do
    it 'requires eight or more characters' do
      invalid_user = build(:user, password: '1234567')
      expect(invalid_user).not_to be_valid
      expect(password_validation_errors(invalid_user)).to include 'is too short'
    end
  end

  it 'validates the format of email addresses' do
    user = User.new(email: 'user_at_example.com')
    expect(user).not_to be_valid
    expect(user.errors).to include :email
  end

  def password_validation_errors(user)
    user.errors.messages[:password].join(' ')
  end
end
