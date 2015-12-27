require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks

if Rails.env.test? || Rails.env.development?
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
end

task checks: [:rubocop, :coffeelint, :whitespace]

task(:default).clear
task default: [:checks, :spec]

if defined?(RSpec)
  RSpec::Core::RakeTask.new(:ci_spec) do |t|
    t.rspec_opts = '-fd --no-color --tag ~exclude_from_ci'
  end
end
