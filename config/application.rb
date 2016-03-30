require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module SleepersAndKeepers
  class Application < Rails::Application
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
    config.active_job.queue_adapter = :sidekiq

    config.generators do |g|
      g.factory_girl false
    end
  end
end
