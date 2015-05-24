FactoryGirl.define do
  factory :league do
    name 'Fantasy Sports Dojo'
    password 'password'
    rounds 15
    size 12
    sport_id 1
    user_id 1
  end

  factory :sport do
    name 'Football'
  end

  factory :team do
    name 'Frontrunners'
    short_name 'Front'
    user_id 1
    league_id 1
  end

  factory :user do
    email 'test-user@example.com'
    first_name 'Test'
    last_name 'User'
    password 'sufficientpassword'
  end
end
