class AppStoreSubscriber
  include Rails.application.routes.url_helpers

  def self.subscribe
    new.change_subscription(:create)
  end

  def self.unsubscribe
    new.change_subscription(:destroy)
  end

  def change_subscription(action)
    hostname = ENV.fetch('INTERNAL_HOST_NAME', ENV.fetch('HOSTS', nil)&.split(',')&.first)
    return if hostname.blank?

    url = app_store_webhook_url(
      host: hostname,
      protocol: 'http'
    )

    method = action == :create ? :post : :delete

    AppStoreClient.new.public_send(
      method,
      { webhook_url: url, subscriber_type: :provider },
      path: 'v1/subscriber'
    )
  rescue StandardError => e
    Sentry.capture_exception(e)
  end
end
