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
      if service == ANY_SERVICE
        allowed_office_codes.fetch(:ALL, []).any?
      else
        allowed_office_codes.fetch(:ALL, []).include?(service.to_s)
      end
    end

    def office_enrolled?(service: ANY_SERVICE)
      if service == ANY_SERVICE
        auth_info.office_codes.any? { allowed_office_codes[_1.to_sym] }
      else
        auth_info.office_codes.any? { allowed_office_codes[_1.to_sym]&.include?(service.to_s) }
      end
    end

    # TODO: implement separately once decided if this is required
    def email_enrolled?
      false
    end

    private

    def allowed_office_codes
      Rails.configuration.x.gatekeeper.office_codes
    end
  end
end
