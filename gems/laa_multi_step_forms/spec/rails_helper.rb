require 'pathname'
ENGINE_ROOT = Pathname.new(File.expand_path('..', __dir__))

require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'

root = defined?(ENGINE_ROOT) ? Pathname.new(ENGINE_ROOT) : Rails.root
require File.expand_path("#{root}/spec/dummy/config/environment", __FILE__)

begin
  ActiveRecord::Migrator.migrations_paths = File.join(ENGINE_ROOT, 'spec/dummy/db/migrate')
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
# Add additional requires below this line. Rails is not loaded until this point!

Rails.root.glob('spec/support/**/*.rb').each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  config.include(ActiveSupport::Testing::TimeHelpers)
  config.include(Devise::Test::ControllerHelpers, type: :controller)
  # config.include(AuthenticationHelpers, type: :controller)

  # As a default, we assume a user is signed in all controllers.
  # For specific scenarios, the user can be "signed off".
  # config.before(:each, type: :controller) { sign_in }

  # Use the faster rack test by default for system specs
  # config.before(:each, type: :integration) { driven_by :rack_test }
  config.include RSpecHtmlMatchers
  config.expect_with :rspec do |c|
    c.max_formatted_output_length = nil
  end
end
