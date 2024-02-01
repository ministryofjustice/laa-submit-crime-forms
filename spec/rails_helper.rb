# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!
require 'sidekiq/testing'
require 'axe-rspec'
Sidekiq::Testing.inline!

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

Capybara.register_driver :headless_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

Capybara.default_driver = Capybara.javascript_driver = :headless_chrome

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  config.include ViewComponent::TestHelpers, type: :component
  config.include(ActiveSupport::Testing::TimeHelpers)
  config.include(Devise::Test::ControllerHelpers, type: :controller)
  config.include(AuthenticationHelpers, type: :controller)
  config.include(AuthenticationHelpers, type: :system)
  config.include RSpecHtmlMatchers
  config.include FactoryBot::Syntax::Methods

  # As a default, we assume a user is signed in all controllers.
  # For specific scenarios, the user can be "signed off".
  config.before(:each, type: :controller) { sign_in }
  # Use the faster rack test by default for system specs if possible
  config.before(:each, type: :system) { driven_by :rack_test }

  config.expect_with :rspec do |c|
    c.max_formatted_output_length = nil
  end

  config.filter_run_excluding :accessibility unless ENV['INCLUDE_ACCESSIBILITY_SPECS'] == 'true'
end

Capybara.configure do |config|
  # Allow us to use the `choose(label_text)` method in browser tests
  # even when the radio button element attached to the label is hidden
  # (as it is using the standard govuk radio element)
  config.automatic_label_click = true
end
