module TestData
  module NsmData
    class Provider
      # TODO: have this return differemnt values based on provider and office_code
      def firm_details(provider)
        {
          'firm_office_attributes' => {
            'name' => '',
            'account_number' => '',
            'address_line_1' => '',
            'address_line_2' => '',
            'town' => '',
            'postcode' => '',
            'vat_registered' => '',
          }
          'solicitor_attributes' => {

          }
        }
      end
    end
  end
end
