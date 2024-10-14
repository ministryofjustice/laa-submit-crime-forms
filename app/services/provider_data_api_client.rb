class ProviderDataApiClient
  class << self
    def contract_active?(office_code)
      query(
        "provider-office/#{office_code}/office-contract-details",
        200 => true,
        204 => false,
      )
    end

    def user_office_details(user_login)
      query(
        "provider-users/#{ERB::Util.url_encode(user_login)}/provider-offices",
        200 => ->(data) { data['officeCodes'] },
        204 => [],
      )
    end

    private

    def query(endpoint, return_values)
      response = HTTParty.get("#{base_url}/#{endpoint}",
                              headers: { 'X-Authorization': api_key })

      unless return_values.key?(response.code)
        raise "Unexpected status code #{response.code} when querying provider API endpoint #{endpoint}"
      end

      if return_values[response.code].respond_to?(:call)
        return_values[response.code].call(response.parsed_response)
      else
        return_values[response.code]
      end
    end

    def base_url
      ENV.fetch('PROVIDER_API_HOST')
    end

    def api_key
      ENV.fetch('PROVIDER_API_KEY')
    end
  end
end
