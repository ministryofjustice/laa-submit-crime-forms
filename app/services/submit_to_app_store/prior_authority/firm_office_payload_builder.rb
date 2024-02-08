class SubmitToAppStore
  module PriorAuthority
    class FirmOfficePayloadBuilder
      def initialize(application)
        @application = application
      end

      def payload
        @application.firm_office.as_json(only: %i[
                                           name
                                           account_number
                                           address_line_1
                                           address_line_2
                                           town
                                           postcode
                                           vat_registered
                                         ])
      end
    end
  end
end
