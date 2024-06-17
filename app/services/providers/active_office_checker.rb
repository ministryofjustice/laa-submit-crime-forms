module Providers
  class ActiveOfficeChecker
    attr_reader :auth_info

    def initialize(auth_info)
      @auth_info = auth_info
    end

    def active_office_codes
      auth_info.office_codes - inactive_office_codes
    end

    private

    def inactive_office_codes
      Rails.configuration.x.inactive_offices.inactive_office_codes
    end
  end
end
