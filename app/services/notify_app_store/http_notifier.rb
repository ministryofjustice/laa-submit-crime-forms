class NotifyAppStore
  class HttpNotifier
    include HTTParty
    headers 'Content-Type' => 'application/json'

    def post(message)
      response = self.class.post("#{host}/application/", body: message.to_json)
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

    def host
      ENV.fetch('APP_STORE_URL', 'http://localhost:8000')
    end
  end
end
