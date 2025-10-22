# frozen_string_literal: true

# Capybara settings (not covered by Rails system tests)

# Increase wait time when running full test suite to account for Chrome startup
Capybara.default_max_wait_time = ENV['CI'] ? 10 : 5

# Normalizes whitespaces when using `has_text?` and similar matchers
Capybara.default_normalize_ws = true

# Where to store artifacts (e.g. screenshots, downloaded files, etc.)
Capybara.save_path = ENV.fetch('CAPYBARA_ARTIFACTS', './tmp/capybara')

# Use fixed server port based on test worker to configure AnyCable broadcast URL
Capybara.server_port = 9887 + ENV['TEST_ENV_NUMBER'].to_i

# Use Puma server for tests (required for proper server startup)
Capybara.server = :puma, { Silent: true, Threads: '0:4' }

# Ensure server starts before any navigation happens
Capybara.always_include_port = true

Capybara.singleton_class.prepend(Module.new do
  attr_accessor :last_used_session

  def using_session(name, &block)
    self.last_used_session = name
    super
  ensure
    self.last_used_session = nil
  end
end)
