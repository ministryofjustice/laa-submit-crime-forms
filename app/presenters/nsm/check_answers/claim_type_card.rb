# frozen_string_literal: true

module Nsm
  module CheckAnswers
    class ClaimTypeCard < Base
      attr_reader :claim, :firm_details_form

      def initialize(claim)
        @group = 'claim_type'
        @section = 'claim_type'
        @claim = claim
        @firm_details_form = Nsm::Steps::FirmDetailsForm.build(claim)
        super()
      end

      def row_data
        claim_rows = magistrates_claim? ? magistrates_rows : breach_rows

        base_rows + claim_rows + final_rows
      end

      def base_rows
        [
          {
            head_key: 'file_ufn',
            text: claim.ufn
          },
          {
            head_key: 'type_of_claim',
            text: I18n.t("laa_crime_forms_common.nsm.claim_type.#{claim.claim_type}")
          }
        ]
      end

      def final_rows
        [
          {
            head_key: 'stage_reached',
            text: translate_table_key(section, claim.stage_reached)
          },
          {
            head_key: 'firm_account_number',
            text: check_missing(firm_details_form.application.office_code)
          },

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
