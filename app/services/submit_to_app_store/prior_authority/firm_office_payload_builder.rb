class SubmitToAppStore
  module PriorAuthority
    class FirmOfficePayloadBuilder
      def initialize(application)
        @application = application
      end

      def payload
        @application.firm_office.as_json(only: %i[
                                           name
                                           address_line_1
                                           address_line_2
                                           town
                                           postcode
                                           vat_registered
                                         ]).merge(account_number: @application.office_code)
      end
    end
  end
end
