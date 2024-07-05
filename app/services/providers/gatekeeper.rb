# This class is used to limit User access
module Providers
  class Gatekeeper
    ANY_SERVICE = :any
    PAA = :crm4
    EOL = :crm5
    NSM = :crm7

    attr_reader :auth_info

    def initialize(auth_info)
      @auth_info = auth_info
    end

    def provider_enrolled?(service: ANY_SERVICE)
      all_enrolled?(service:) || office_enrolled?(service:)
    end

    def provider_enrolled_and_active?(service: ANY_SERVICE)
      active_office_codes(service:).any?
    end

    def active_office_codes(service: ANY_SERVICE)
      provider_office_codes_for(service:) - inactive_office_codes
    end

    private

    def all_enrolled?(service: ANY_SERVICE)
      allowed_office_codes = allowed_office_codes(service:)
      allowed_office_codes.include?('ALL')
    end

    def office_enrolled?(service: ANY_SERVICE)
      provider_office_codes_for(service:).any?
    end

    def provider_office_codes_for(service: ANY_SERVICE)
      if all_enrolled?(service:)
        auth_info.office_codes
      else
        auth_info.office_codes & allowed_office_codes(service:)
      end
    end

    def allowed_office_codes(service: ANY_SERVICE)
      if service == ANY_SERVICE
        all_office_codes
      else
        offices_codes_for(service)
      end
    end

    def all_office_codes
      @all_office_codes ||= offices_codes_for(PAA) |
                            offices_codes_for(EOL) |
                            offices_codes_for(NSM)
    end

    def offices_codes_for(service)
      Rails.configuration.x.gatekeeper.send(service).office_codes || []
    end

    def inactive_office_codes
      Rails.configuration.x.inactive_offices.inactive_office_codes
    end
  end
end
