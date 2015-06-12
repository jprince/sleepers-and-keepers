user = User.where(email: 'user@example.com')

if user.blank?
  user = user.build
  user.first_name = 'Test'
  user.last_name = 'User'
  user.password = 'asdASD123!@#'
  user.save validate: false
end

DraftStatus.where(description: 'Not Started').first_or_create!
DraftStatus.where(description: 'In Progress').first_or_create!
DraftStatus.where(description: 'Complete').first_or_create!
Sport.seed
