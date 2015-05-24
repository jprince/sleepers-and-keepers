FactoryGirl.define do
  FactoryGirl.define do
    sequence :email do |n|
      "user-#{n}@example.com"
    end
  end

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
    name Faker::Commerce.product_name
    short_name Faker::Commerce.product_name.slice(0, 9)
    user_id 1
    league_id 1
  end

  factory :user do
    email
    first_name Faker::Name.first_name
    last_name Faker::Name.last_name
    password 'sufficientpassword'
  end
end
