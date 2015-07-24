FactoryGirl.define do
  FactoryGirl.define do
    sequence(:email) { |n| "user-#{n}@example.com" }
  end

  factory :draft_status do
    description 'Not Started'
  end

  factory :league do
    draft_status
    name 'Fantasy Sports Dojo'
    password 'password'
    rounds 15
    size 12
    user

    factory :football_league do
      sport
    end

    trait :with_draft_complete do
      draft_status { create(:draft_status, description: 'Complete') }
    end

    trait :with_draft_in_progress do
      before(:create) { create(:draft_status) }
      draft_status { create(:draft_status, description: 'In Progress') }
    end
  end

  factory :pick do
    overall_pick 1
    player
    round 1
    round_pick 1
    team
    keeper false
  end

  factory :player do
    first_name { Faker::Name.first_name }
    headline 'New player news'
    injury '2 weeks: Sprained ankle'
    last_name { Faker::Name.last_name }
    orig_id '1'
    photo_url 'http://img1.nymag.com/imgs/daily/vulture/2013/09/19/19-keypeele.w529.h529.2x.jpg'
    position 'RB'
    pro_status 'A'
    sport
    team 'NYJ'
  end

  factory :sport do
    name 'Football'
    positions %w(QB RB WR TE K DST)
  end

  factory :team do
    draft_pick { League.last.size - League.last.teams.length }
    league
    sequence(:name) { |n| Faker::Commerce.product_name + " (#{n})" }
    short_name { Faker::Commerce.product_name.slice(0, 9) }
    user
  end

  factory :user do
    email
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    password 'sufficientpassword'
  end
end
