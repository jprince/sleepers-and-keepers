uri = URI.parse(Rails.application.secrets.redis_to_go_url)
REDIS = Redis.new(:url => uri)
