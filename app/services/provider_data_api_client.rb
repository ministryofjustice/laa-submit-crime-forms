class ProviderDataApiClient
  include HTTParty

  base_uri ENV.fetch('PROVIDER_API_HOST')
  headers 'X-Authorization' => ENV.fetch('PROVIDER_API_KEY')
  format :json

  class << self
    def contract_active?(office_code)
      query(
        :head,
        "/provider-offices/#{office_code}/schedules?areaOfLaw=CRIME%20LOWER",
        200 => :active,
        404 => :unavailable,
        204 => :inactive
      )
    end

    def user_office_details(user_login)
      encoded_login = ERB::Util.url_encode(user_login)

      query(
        :get,
        "/api/v1/provider-users/#{encoded_login}/provider-offices",
        200 => ->(data) { data['offices'] },
        204 => []
      )
    end

    private

    def query(method, endpoint, handlers)
      response = send(method, endpoint)
      unless handlers.key?(response.code)
        raise "Unexpected status code #{response.code} when querying provider API endpoint #{endpoint}"
      end

      handler = handlers[response.code]
      handler.respond_to?(:call) ? handler.call(response.parsed_response) : handler
    end
  end
end
