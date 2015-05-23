require 'capybara/poltergeist'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, timeout: 10_000)
end

Capybara.javascript_driver = :poltergeist
Capybara::Screenshot.prune_strategy = :keep_last_run
