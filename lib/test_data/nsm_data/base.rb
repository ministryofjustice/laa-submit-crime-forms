module TestData
  module NsmData
    class Base
      attr_reader :date, :provider

      def initialize(date, provider)
        @date = date
        @provider = provider
      end

      def claim_type
        @claim_type ||= {
          'ufn' => SecureRandom.uuid,
          'claim_type' => ::ClaimType::NON_STANDARD_MAGISTRATE,
          'rep_order_date' => date
        }
      end

      def firm_details
        Provider.new.firm_details(provider)
      end

      def disbursement_details
        {
          'first_name' => '',
          'last_name' => '',
          'maat' => ''
        }
      end

      def case_details; end

      def hearing_details; end

      def case_disposal; end

      def reason_for_claim; end

      def claim_details; end

      def work_item; end

      def letters_calls; end

      def disbursement_cost; end

      def disbursement_type; end

      def other_info; end

      def supporting_evidence; end

      def answer_equality; end

      def equality_questions; end

      def solicitor_declaration; end
    end
  end
end
