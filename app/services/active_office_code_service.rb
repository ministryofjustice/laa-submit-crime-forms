class ActiveOfficeCodeService
  class << self
    def call(office_codes)
      office_codes.select { active?(_1) }
    end

    def active?(office_code)
      return true if always_active_office_codes.include?(office_code)
      return false if always_inactive_office_codes.include?(office_code)

      contract_active?(office_code)
    end

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

    def base_url
      ENV.fetch('PROVIDER_API_HOST')
    end

    def api_key
      ENV.fetch('PROVIDER_API_KEY')
    end

    def always_inactive_office_codes
      Rails.configuration.x.office_code_overrides.inactive_office_codes
    end

    def always_active_office_codes
      Rails.configuration.x.office_code_overrides.active_office_codes
    end
  end
end
