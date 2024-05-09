# frozen_string_literal: true

module Nsm
  module CheckAnswers
    class ClaimTypeCard < Base
      attr_reader :claim

      def initialize(claim)
        @group = 'claim_type'
        @section = 'claim_type'
        @claim = claim
      end

      def row_data
        claim_rows = magistrates_claim? ? magistrates_rows : breach_rows

        base_rows + claim_rows
      end

      def base_rows
        [
          {
            head_key: 'laa_reference',
            text: claim.laa_reference
          },
          {
            head_key: 'file_ufn',
            text: claim.ufn
          },
          {
            head_key: 'type_of_claim',
            text: translate_table_key(section, claim.claim_type)
          }
        ]
      end

      def magistrates_rows
        [
          {
            head_key: 'rep_order_date',
            text: claim.rep_order_date&.to_fs(:stamp)
          }
        ]
      end

      def breach_rows
        [
          {
            head_key: 'cntp_number',
            text: claim.cntp_order
          },
          {
            head_key: 'cntp_rep_order',
            text: claim.cntp_date&.to_fs(:stamp)
          }
        ]
      end

      def magistrates_claim?
        claim.claim_type == ClaimType::NON_STANDARD_MAGISTRATE.to_s
      end
    end
  end
end
