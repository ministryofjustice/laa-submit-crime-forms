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
      email_enrolled? || all_enrolled?(service:) || office_enrolled?(service:)
    end

    def all_enrolled?(service: ANY_SERVICE)
      allowed_office_codes = allowed_office_codes(service:)
      allowed_office_codes.include?('ALL')
    end

    def office_enrolled?(service: ANY_SERVICE)
      allowed_office_codes = allowed_office_codes(service:)
      auth_info.office_codes.any? { |el| allowed_office_codes.include?(el) }
    end

    # TODO: implement separately once decided if this is required
    def email_enrolled?
      false
    end

    private

    def allowed_office_codes(service: ANY_SERVICE)
      if service == ANY_SERVICE
        all_office_codes
      else
        Rails.configuration.x.gatekeeper.send(service).office_codes
      end
    end

    def all_office_codes
      @all_office_codes ||= Rails.configuration.x.gatekeeper.crm4.office_codes |
                            Rails.configuration.x.gatekeeper.crm5.office_codes |
                            Rails.configuration.x.gatekeeper.crm7.office_codes
    end
  end
end
