class AppStoreSubscriber
  include Rails.application.routes.url_helpers

  def self.call
    new.subscribe
  end

  def subscribe
    return if ENV['HOSTS'].blank?

    url = app_store_webhook_url(
      host: ENV.fetch('HOSTS', nil),
      protocol: ENV.fetch('PROTOCOL', 'https')
    )

    AppStoreClient.new.post(
      { webhook_url: url, subscriber_type: :provider },
      path: 'v1/subscriber'
    )
  rescue StandardError => e
    Sentry.capture_exception(e)
  end
end
