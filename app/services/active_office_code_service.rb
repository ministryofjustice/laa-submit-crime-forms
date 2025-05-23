class ActiveOfficeCodeService
  class << self
    def call(office_codes)
      office_codes.select { active?(_1) }
    end

    def active?(office_code)
      always_inactive_office_codes.exclude?(office_code)
    end

    def always_inactive_office_codes
      Rails.configuration.x.office_code_overrides.inactive_office_codes
    end
  end
end
