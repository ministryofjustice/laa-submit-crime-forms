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

redis_url = Rails.configuration.x.redis_url

module Dashboard; end

Rails.logger.info("[Sidekiq] Application config initialising...")

Sidekiq.configure_client do |config|
  Rails.logger.info("[SidekiqClient] configuring sidekiq client...")
  config.logger.level = Logger::WARN if Rails.env.test?
  config.redis = { url: redis_url } if redis_url
end

Sidekiq.configure_server do |config|
  Rails.logger.info("[SidekiqServer] configuring sidekiq server...")
  config.redis = { url: redis_url } if redis_url

  return unless ENV.fetch("ENABLE_PROMETHEUS_EXPORTER", "false") == "true"

  Rails.logger.info("[SidekiqPrometheusExporter] Instrumentation for sidekiq server...")
  require "sidekiq/api"
  require 'prometheus_exporter/client'
  require 'prometheus_exporter/instrumentation'

  # Taken from https://github.com/discourse/prometheus_exporter?tab=readme-ov-file#sidekiq-metrics
  #
  config.server_middleware do |chain|
    Rails.logger.info "[SidekiqPrometheusExporter] Chaining middleware..."
    chain.add PrometheusExporter::Instrumentation::Sidekiq
  end
  config.death_handlers << PrometheusExporter::Instrumentation::Sidekiq.death_handler
  config.on :startup do
    Rails.logger.info "[SidekiqPrometheusExporter] Startup instrumention details..."

    PrometheusExporter::Instrumentation::Process.start type: 'sidekiq'
    PrometheusExporter::Instrumentation::SidekiqProcess.start
    PrometheusExporter::Instrumentation::SidekiqQueue.start(all_queues: true)
    PrometheusExporter::Instrumentation::SidekiqStats.start
  end

  at_exit do
    PrometheusExporter::Client.default.stop(wait_timeout_seconds: 10)
  end
end
