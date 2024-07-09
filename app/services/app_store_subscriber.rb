class AppStoreSubscriber
  include Rails.application.routes.url_helpers

  def self.call
    new.subscribe
  end

  def subscribe
    hostname = ENV.fetch('INTERNAL_HOST_NAME', ENV.fetch('HOSTS', nil)&.split(',')&.first)
    return if hostname.blank?

    url = app_store_webhook_url(
      host: hostname,
      protocol: 'http'
    )

    AppStoreClient.new.post(
      { webhook_url: url, subscriber_type: :provider },
      path: 'v1/subscriber'
    )
  rescue StandardError => e
    Sentry.capture_exception(e)
  end
end
