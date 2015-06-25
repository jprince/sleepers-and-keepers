require 'capybara/poltergeist'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    extensions: ['vendor/assets/javascripts/poltergeist/bind_polyfill.js']
  )
end

Capybara.javascript_driver = :poltergeist
Capybara::Screenshot.prune_strategy = :keep_last_run
