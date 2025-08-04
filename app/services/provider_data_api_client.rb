class ProviderDataApiClient
  class << self
    def contract_active?(office_code)
      query(
        "provider-office/#{office_code}/schedules",
        200 => ->(data) { valid_crime_contract?(data) },
        204 => false,
      )
    end

    def user_office_details(user_login)
      if FeatureFlags.provider_api_v1.enabled?
        query(
          "api/v1/provider-users/#{ERB::Util.url_encode(user_login)}/provider-offices",
          200 => ->(data) { data['offices'] },
          204 => [],
        )
      else
        query(
          "provider-users/#{ERB::Util.url_encode(user_login)}/provider-offices",
          200 => ->(data) { data['officeCodes'] },
          204 => [],
        )
      end
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

    def valid_crime_contract?(schedules)
      schedules['schedules']&.any? { valid_crime_schedule?(_1) }
    end

    def valid_crime_schedule?(schedule)
      schedule.fetch('areaOfLaw', '').upcase.start_with?('CRIME') &&
        schedule.fetch('contractStatus', '').upcase == 'OPEN' &&
        schedule.fetch('scheduleEndDate', Date.current - 1).to_date.future?
    end
  end
end
