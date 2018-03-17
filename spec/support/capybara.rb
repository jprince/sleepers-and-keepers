require 'capybara/rails'
require 'capybara/rspec'
require 'capybara-screenshot/rspec'

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w[headless disable-gpu] }
  )

  Capybara::Selenium::Driver.new(app, browser: :chrome, desired_capabilities: capabilities)
end

Capybara::Screenshot.register_driver :headless_chrome do |driver, path|
  driver.save_screenshot(path)
end

Capybara.server = :puma
Capybara.javascript_driver = :headless_chrome
Capybara::Screenshot.prune_strategy = :keep_last_run
