module Assess
  module ClaimDetails
    class Table
      KEYS = %i[
        details_of_claim
        defendant_details
        case_details
        case_disposal
        claim_justification
        claim_details
        hearing_details
        other_info
        contact_details
        equality_details
      ].freeze

      attr_reader :claim

      def initialize(claim)
        @claim = claim
      end

      def table
        KEYS.map do |key|
          BaseViewModel.build(key, claim).rows
        end
      end
    end
  end
end
