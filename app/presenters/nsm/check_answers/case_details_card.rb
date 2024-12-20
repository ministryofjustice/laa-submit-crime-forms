# frozen_string_literal: true

module Nsm
  module CheckAnswers
    class CaseDetailsCard < Base
      attr_reader :claim

      def initialize(claim)
        @claim = claim
        @group = 'about_case'
        @section = 'case_details'
        super()
      end

      def row_data
        row = [
          main_offence_row,
          main_offence_type_row,
          main_offence_date_row,
          assigned_counsel_row,
          unassigned_counsel_row,
          agent_instructed_row,
          remitted_to_magistrate_row
        ]

        remove_main_offence_type(row) unless claim.main_offence_type
        row.flatten
      end

      private

      def remove_main_offence_type(row)
        row.delete_if { |r| r.is_a?(Hash) && r[:head_key] == 'main_offence_type' }
      end

      def main_offence_row
        {
          head_key: 'main_offence',
          text: check_missing(claim.main_offence)
        }
      end

      def main_offence_type_row
        {
          head_key: 'main_offence_type',
          text: check_missing(claim.main_offence_type.present?) do
            I18n.t("nsm.steps.check_answers.show.sections.case_details.#{claim.main_offence_type}")
          end
        }
      end

      def main_offence_date
        {
          head_key: 'main_offence_date',
            text: check_missing(claim.main_offence_date) do
                    claim.main_offence_date.to_fs(:stamp)
                  end
        }
      end

      def assigned_counsel_row
        {
          head_key: 'assigned_counsel',
          text: check_missing(claim.assigned_counsel.present?) do
                  claim.assigned_counsel.capitalize
                end
        }
      end

      def unassigned_counsel_row
        {
          head_key: 'unassigned_counsel',
          text: check_missing(claim.unassigned_counsel.present?) do
                  claim.unassigned_counsel.capitalize
                end
        }
      end

      def agent_instructed_row
        {
          head_key: 'agent_instructed',
          text: check_missing(claim.agent_instructed.present?) do
                  claim.agent_instructed.capitalize
                end
        }
      end

      def remitted_to_magistrate_row
        process_boolean_value(boolean_field: claim.remitted_to_magistrate,
                              value_field: claim.remitted_to_magistrate_date,
                              boolean_key: 'remitted_to_magistrate',
                              value_key: 'remitted_to_magistrate_date') do
          claim.remitted_to_magistrate_date.to_fs(:stamp)
        end
      end
    end
  end
end
