class ActiveOfficeCodeService
  class << self
    delegate :contract_active?, to: :ProviderDataApiClient

    def call(office_codes)
      office_codes.select { active?(_1) }
    end

    def active?(office_code)
      return true if always_active_office_codes.include?(office_code)
      return false if always_inactive_office_codes.include?(office_code)
      return contract_active?(office_code) if FeatureFlags.provider_api_login_check.enabled?

      true
    end

    def always_inactive_office_codes
      Rails.configuration.x.office_code_overrides.inactive_office_codes
    end

    def always_active_office_codes
      Rails.configuration.x.office_code_overrides.active_office_codes
    end
  end
end
