class NotifyAppStore
  class HttpNotifier
    include HTTParty
    headers 'Content-Type' => 'application/json'

    def post(message)
      response = self.class.post("#{host}/application/", **options(message))

      case response.code
      when 201
        :success
      when 409
        # can be ignored but should be notified so we can track when it occurs
        Sentry.capture_message("Application ID already exists in AppStore for '#{message[:application_id]}'")
        :warning
      else
        raise "Unexpected response from AppStore - status #{response.code} for '#{message[:application_id]}'"
      end
    end

    private

    def options(message)
      options = { body: message.to_json }
      return options if ENV['APP_STORE_USERNAME'].blank?

      options.merge(
        basic_auth: {
          username: ENV.fetch('APP_STORE_USERNAME', nil),
          password: ENV.fetch('APP_STORE_PASSWORD')
        }
      )
    end

    def host
      ENV.fetch('APP_STORE_URL', 'http://localhost:8000')
    end
  end
end
