# Puma Workers * (Puma Threads / 2) * Heroku Web Dynos
Sidekiq.configure_client do |config|
  config.redis = { url: Rails.application.secrets.redis_to_go_url, :size => 5 }
end

# (Redis Connection Limit - Client Size - 2) / Heroku Job Dynos
Sidekiq.configure_server do |config|
  config.redis = { url: Rails.application.secrets.redis_to_go_url, :size => 30 }
end
