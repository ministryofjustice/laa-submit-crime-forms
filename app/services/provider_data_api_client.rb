class ProviderDataApiClient
  class << self
    def contract_active?(office_code)
      response = HTTParty.get("#{base_url}/provider-office/#{office_code}/office-contract-details",
                              headers: { 'X-Authorization': api_key })

      case response.code
      when 200
        true
      when 204
        false
      else
        raise "Unexpected status code #{response.code} when checking office code #{office_code}"
      end
    end

    def user_details(email)
      response = HTTParty.get("#{base_url}/provider-users/exists?userEmail=#{email}",
                              headers: { 'X-Authorization': api_key })

      case response.code
      when 200
        response.parsed_response['user']
      else
        raise "Unexpected status code #{response.code} when checking for user with email #{email}"
      end
    end

    def user_office_details(user_login)
      response = HTTParty.get("#{base_url}/provider-users/#{user_login}/provider-offices",
                              headers: { 'X-Authorization': api_key })

      case response.code
      when 200
        response.parsed_response['officeCodes']
      when 204
        []
      else
        raise "Unexpected status code #{response.code} when checking for office codes for user #{user_login}"
      end
    end

    private

    def base_url
      ENV.fetch('PROVIDER_API_HOST')
    end

    def api_key
      ENV.fetch('PROVIDER_API_KEY')
    end
  end
end
