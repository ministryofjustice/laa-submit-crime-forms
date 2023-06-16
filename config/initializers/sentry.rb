Sentry.init do |config|
  config.dsn = 'https://b3bce9495e484872ae0ab2aeeaedbd54@o345774.ingest.sentry.io/4505369863651328'

  # Set traces_sample_rate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = 1.0
  # or
  config.traces_sampler = lambda do |context|
    true
  end
end