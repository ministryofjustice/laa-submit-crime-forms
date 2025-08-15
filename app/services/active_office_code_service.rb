class ActiveOfficeCodeService
  class << self
    delegate :contract_active?, to: :ProviderDataApiClient

    def call(office_codes)
      office_codes.select { active?(_1) }
    end

    def active?(office_code)
      result = if FeatureFlags.provider_api_login_check.enabled?
                 contract_active?(office_code)
               else
                 :unavailable
               end

      case result
      when :active then true
      when :inactive then false
      when :unavailable then known_active_code?(office_code)
      # Can't trigger this as contract_active? only returns on the
      # the symbols above
      # :nocov:
      else
        raise "Unexpected result #{result} when querying provider API for office codes"
      end
      # :nocov:
    end

    private

    def known_active_code?(office_code)
      return true if always_active_office_codes.include?(office_code)
      return false if always_inactive_office_codes.include?(office_code)

      false
    end

    def always_inactive_office_codes
      Rails.configuration.x.office_code_overrides.inactive_office_codes
    end

    def always_active_office_codes
      Rails.configuration.x.office_code_overrides.active_office_codes
    end
  end
end
