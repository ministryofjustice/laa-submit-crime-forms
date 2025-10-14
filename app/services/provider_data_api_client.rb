class ProviderDataApiClient
  include HTTParty

  base_uri ENV.fetch('PROVIDER_API_HOST')
  headers 'X-Authorization' => ENV.fetch('PROVIDER_API_KEY')
  format :json

  class << self
    def contract_active?(office_code, effective_date = nil)
      # :nocov: Querying an external API
      params = {
        'areaOfLaw' => 'CRIME LOWER',
        'effectiveDate' => effective_date&.strftime('%d-%m-%Y')
      }.compact
      # :nocov:

      query(
        :head,
        "/provider-offices/#{office_code}/schedules?#{URI.encode_www_form(params)}",
        {
          200 => :active,
          204 => :inactive
        },
        :unavailable
      )
    end

    def user_office_details(user_login)
      encoded_login = ERB::Util.url_encode(user_login)

      query(
        :get,
        "/api/v1/provider-users/#{encoded_login}/provider-offices",
        {
          200 => ->(data) { data['offices'] },
          204 => []
        }
      )
    end

    private

    def query(method, endpoint, handlers, fallback = nil)
      response = send(method, endpoint)
      unless handlers.key?(response.code)
        return fallback if fallback

        raise "Unexpected status code #{response.code} when querying provider API endpoint #{endpoint}"
      end

      handler = handlers[response.code]
      handler.respond_to?(:call) ? handler.call(response.parsed_response) : handler
    end
  end
end
