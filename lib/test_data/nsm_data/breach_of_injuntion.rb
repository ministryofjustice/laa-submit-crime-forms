module TestData
  module NsmData
    class BreachOfInjunction
      attr_reader :date, :provider

      def initialize(date, provider)
        @date = date
        @provider = provider
      end

      def claim_type
        @claim_type ||= {
          'ufn' => SecureRandom.uuid,
          'claim_type' => ::ClaimType::BREACH_OF_INJUNCTION,
          'cntp_order' => date,
          'cntp_date' => ''
        }
      end

      def disbursement_details
        {
          'first_name' => '',
          'last_name' => '',
        }
      end
    end
  end
end
