namespace :players do
  desc 'Updates player data'
  task :update do
    Player.update_player_pool
  end
end
