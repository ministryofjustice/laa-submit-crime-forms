# frozen_string_literal: true

# Sidekiq uses Redis to store all of its job and operational data.
# By default, Sidekiq tries to connect to Redis at localhost:6379
#
# You can also set the Redis url using environment variables.
# The generic REDIS_URL may be set to specify the Redis server.
#
# Otherwise it can be configured here using both the blocks
# Sidekiq.configure_server and Sidekiq.configure_client
#
# https://github.com/mperham/sidekiq/wiki/Using-Redis

Sidekiq.default_job_options = { retry: 5 }

# Perform Sidekiq jobs immediately in development,
# so you don't have to run a separate process.
# You'll also benefit from code reloading.
if ENV.fetch('RUN_SIDEKIQ_IN_TEST_MODE', false) == "true"
  require 'sidekiq/testing'
  Sidekiq::Testing.inline!
end

if ENV['REDIS_HOST'].present? && ENV['REDIS_PASSWORD'].present?
  protocol = ENV.fetch("REDIS_PROTOCOL", "rediss")
  redis_url = "#{protocol}://:#{ENV.fetch('REDIS_PASSWORD',
                                     nil)}@#{ENV.fetch('REDIS_HOST',
                                                       nil)}:6379"
end

module Dashboard; end

Sidekiq.configure_client do |config|
  config.logger.level = Logger::WARN if Rails.env.test?
  config.redis = { url: redis_url } if redis_url
end

Sidekiq.configure_server do |config|
  config.redis = { url: redis_url } if redis_url
end
