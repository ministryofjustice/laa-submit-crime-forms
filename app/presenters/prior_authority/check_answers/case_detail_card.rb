# frozen_string_literal: true

module PriorAuthority
  module CheckAnswers
    class CaseDetailCard < Base
      attr_reader :application

      def initialize(application)
        @group = 'about_case'
        @section = 'case_detail'
        @application = application
        super()
      end

      def row_data
        base_rows
      end

      def base_rows
        [
          main_offence_row,
          rep_order_date_row,
          maat_row,
          client_detained_row,
          subject_to_poca_row
        ]
      end

      def completed?
        PriorAuthority::Tasks::CaseAndHearingDetail.new(application:).case_detail_completed?
      end

      private

      def main_offence_row
        {
          head_key: 'main_offence',
          text: check_missing(main_offence)
        }
      end

      def rep_order_date_row
        {
          head_key: 'rep_order_date',
          text: check_missing(application.rep_order_date&.to_fs(:stamp)),
        }
      end

      def maat_row
        {
          head_key: 'maat',
          text: check_missing(application.defendant.maat),
        }
      end

      def client_detained_row
        {
          head_key: 'client_detained',
          text: check_missing(client_detained),
        }
      end

      def subject_to_poca_row
        {
          head_key: 'subject_to_poca',
          text: I18n.t("generic.#{application.subject_to_poca}"),
        }
      end

      def client_detained
        @client_detained ||= if application.client_detained?
                               if application.prison_id == 'custom'
                                 check_missing(application.custom_prison_name)
                               else
                                 check_missing(application.prison_id, I18n.t("prior_authority.prisons.#{application.prison_id}"))
                               end
                             else
                               check_missing(application.client_detained?, I18n.t("generic.#{application.client_detained?}"))
                             end
      end

      def main_offence
        if application.main_offence_id == 'custom'
          check_missing(application.custom_main_offence_name)
        else
          check_missing(application.main_offence_id, I18n.t("prior_authority.offences.#{application.main_offence_id}"))
        end
      end
    end
  end
end
