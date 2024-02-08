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

      # rubocop:disable Metrics/MethodLength
      def base_rows
        [
          {
            head_key: 'main_offence',
            text: application.main_offence,
          },
          {
            head_key: 'rep_order_date',
            text: application.rep_order_date.to_fs(:stamp),
          },
          {
            head_key: 'maat',
            text: application.defendant.maat,
          },
          {
            head_key: 'client_detained',
            text: client_detained,
          },
          {
            head_key: 'subject_to_poca',
            text: I18n.t("generic.#{application.subject_to_poca}"),
          },
        ]
      end
      # rubocop:enable Metrics/MethodLength

      private

      def client_detained
        @client_detained ||= if application.client_detained?
                               application.client_detained_prison
                             else
                               I18n.t("generic.#{application.client_detained?}")
                             end
      end
    end
  end
end
