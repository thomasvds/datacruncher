ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'minitest/reporters'
require 'database_cleaner'
require 'capybara/rails'
require 'capybara/poltergeist'
# include Warden::Test::Helpers


# TEST FRAMEWORK CONFIGURATIONS
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]
DatabaseCleaner.strategy = :truncation

Capybara.default_driver = :poltergeist
options = {:js_errors => false}
Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, options)
end

# CONFIG WITH PHANTOM.JS
Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, :phantomjs => Phantomjs.path)
end

# Warden.test_mode!

# TOP-LEVEL TEST CLASSES SETTINGS
class ActiveSupport::TestCase
  fixtures :all
end

class ActionDispatch::IntegrationTest

  include Capybara::DSL

  # Ensure that Capybara uses the test db for the integration
  # testing (vs. using fixtures). Fixtures can still be enabled
  # individually for each test class if required
  self.use_transactional_fixtures = false

  def setup
    # Populate the test db for each test run (using seeds.rb)
    Rails.application.load_seed
  end

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
    # Ensures that the test db gets dropped after each run,
    # otherwise each seed continues adding rows to the same db
    DatabaseCleaner.clean
    # Warden.test_reset!
  end
end




