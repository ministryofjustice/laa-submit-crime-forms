class ProviderDataApiClient
  class << self
    def contract_active?(office_code)
      query(
        "provider-office/#{office_code}/office-contract-details",
        200 => ->(_) { true },
        204 => ->(_) { false },
      )
    end

    def user_details(email)
      query(
        "provider-users/exists?userEmail=#{email}",
        200 => ->(data) { data['user'] }
      )
    end

    def user_office_details(user_login)
      query(
        "provider-users/#{user_login}/provider-offices",
        200 => ->(data) { data['officeCodes'] },
        204 => ->(_) { [] },
      )
    end

    private

    def query(endpoint, return_values)
      response = HTTParty.get("#{base_url}/#{endpoint}",
                              headers: { 'X-Authorization': api_key })

      unless return_values.key?(response.code)
        raise "Unexpected status code #{response.code} when querying provider API endpoint #{endpoint}"
      end

      return_values[response.code].call(response.parsed_response)
    end

    def base_url
      ENV.fetch('PROVIDER_API_HOST')
    end

    def api_key
      ENV.fetch('PROVIDER_API_KEY')
    end
  end
end
