uri = URI.parse(Rails.application.secrets.redit_to_go_url)
REDIS = Redis.new(:url => uri)
