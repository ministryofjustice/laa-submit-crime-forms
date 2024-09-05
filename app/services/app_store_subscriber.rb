class AppStoreSubscriber
  include Rails.application.routes.url_helpers

  MAX_ATTEMPTS = 3
  SECONDS_BETWEEN_RETRIES = 3

  def self.subscribe
    attempts = 0
    begin
      new.change_subscription(:create)
    rescue StandardError => e
      attempts += 1
      if attempts < 3
        # Sometimes a freshly minted pod fails to connect to Microsoft to generate a token,
        # but the issue should resolve itself automatically. Therefore we retry after a short
        # sleep
        sleep SECONDS_BETWEEN_RETRIES
        retry
      else
        Sentry.capture_exception(e)
      end
    end
  end

  def self.unsubscribe
    new.change_subscription(:destroy)
  rescue StandardError => e
    Sentry.capture_exception(e)
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
  end
end
