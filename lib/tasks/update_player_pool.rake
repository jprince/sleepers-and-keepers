namespace :players do
  desc 'Updates player data'
  task update: :environment do
    Player.update_player_pool
  end
end
