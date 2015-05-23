FactoryGirl.define do
  factory :user do
    email 'test-user@example.com'
    first_name 'Test'
    last_name 'User'
    password 'sufficientpassword'
  end
end
