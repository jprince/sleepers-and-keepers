user = User.where(email: 'user@example.com')

if user.blank?
  user = user.build
  user.first_name = 'Test'
  user.last_name = 'User'
  user.password = 'asdASD123!@#'
  user.save validate: false
end

Sport.seed
Player.update_player_pool
