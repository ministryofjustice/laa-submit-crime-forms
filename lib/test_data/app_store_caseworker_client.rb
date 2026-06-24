module TestData
  class AppStoreCaseworkerClient
    include HTTParty

    headers 'Content-Type' => 'application/json'

    def put(message)
      raise 'Caseworker test data submissions require local App Store without OAuth' if oauth_configured?

      response = self.class.put(
        "#{host}/v1/application/#{message[:application_id]}",
        body: message.to_json,
        headers: { 'X-Client-Type': 'caseworker' }
      )

      case response.code
      when 201
        JSON.parse(response.body)
      else
        raise "Unexpected response from AppStore - status #{response.code} for '#{message[:application_id]}'"
      end
    end

    private

    def oauth_configured?
      AppStoreTokenProvider.instance.authentication_configured?
    end

    def host
      ENV.fetch('APP_STORE_URL', 'http://localhost:8000')
    end
  end
end
