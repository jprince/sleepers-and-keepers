user = User.where(email: 'user@example.com')

if user.blank?
  user = user.build
  user.first_name = 'Test'
  user.last_name = 'User'
  user.password = 'asdASD123!@#'
  user.save validate: false
end

Sport.where(name: 'Football').first_or_create!
Sport.where(name: 'Baseball').first_or_create!
