# frozen_string_literal: true

module Nsm
  module CheckAnswers
    class ClaimDetailsCard < Base
      attr_reader :claim

      def initialize(claim)
        @claim = claim
        @group = 'about_claim'
        @section = 'claim_details'
        super()
      end

      def row_data
        [
          prosecution_evidence_row,
          defence_statement_row,
          number_of_witnesses_row,
          supplemental_claim_row,
          preparation_time_row,
          work_before_row,
          work_after_row,
          work_completed_row,
          wasted_costs_row,
        ].flatten
      end

      private

      def prosecution_evidence_row
        {
          head_key: 'prosecution_evidence',
          text: check_missing(claim.prosecution_evidence)
        }
      end

      def defence_statement_row
        {
          head_key: 'defence_statement',
          text: check_missing(claim.defence_statement)
        }
      end

      def number_of_witnesses_row
        {
          head_key: 'number_of_witnesses',
          text: check_missing(claim.number_of_witnesses)
        }
      end

      def supplemental_claim_row
        {
          head_key: 'supplemental_claim',
          text: check_missing(claim.supplemental_claim.present?) do
                  claim.supplemental_claim.capitalize
                end
        }
      end

      def preparation_time_row
        process_boolean_value(boolean_field: claim.preparation_time, value_field: claim.time_spent,
                              boolean_key: 'preparation_time', value_key: 'time_spent') do
          ApplicationController.helpers.format_period(claim.time_spent)
        end
      end

      def work_before_row
        process_boolean_value(boolean_field: claim.work_before, value_field: claim.work_before_date,
                              boolean_key: 'work_before', value_key: 'work_before_date') do
          claim.work_before_date.to_fs(:stamp)
        end
      end

      def work_after_row
        process_boolean_value(boolean_field: claim.work_after, value_field: claim.work_after_date,
                              boolean_key: 'work_after', value_key: 'work_after_date') do
          claim.work_after_date.to_fs(:stamp)
        end
      end

      def work_completed_row
        {
          head_key: 'work_completed_date',
          text: check_missing(claim.work_completed_date&.to_fs(:stamp))
        }
      end

      def wasted_costs_row
        {
          head_key: 'wasted_costs',
          text: check_missing(claim.wasted_costs.present?) do
            claim.wasted_costs.capitalize
          end
        }
      end
    end
  end
end
