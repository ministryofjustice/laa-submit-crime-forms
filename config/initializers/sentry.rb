require Rails.root.join('lib/host_env')

EXCLUDE_PATHS = %w[/ping /ping.json /health /health.json].freeze

if ENV.fetch('SENTRY_DSN', nil).present?
  Sentry.init do |config|
    config.environment = HostEnv.env_name
    config.dsn = ENV['SENTRY_DSN']
    config.breadcrumbs_logger = [:active_support_logger]
    config.release = ENV.fetch('BUILD_TAG', 'unknown')

    # Don't log RetryJobError exceptions in Sentry as they will have already been logged as part of the failed job
    config.excluded_exceptions += ['RetryJobError']

    # Set traces_sample_rate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    # We recommend adjusting this value in production.
    config.traces_sampler = lambda do |sampling_context|
      transaction_context = sampling_context[:transaction_context]
      transaction_name = transaction_context[:name]

      transaction_name.in?(EXCLUDE_PATHS) ? 0.0 : 0.05
    end

    # Opt in to new Rails error reporting API
    # https://edgeguides.rubyonrails.org/error_reporting.html
    config.rails.register_error_subscriber = true
  end
end
