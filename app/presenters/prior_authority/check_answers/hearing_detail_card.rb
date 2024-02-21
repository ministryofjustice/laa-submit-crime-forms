# frozen_string_literal: true

module PriorAuthority
  module CheckAnswers
    class HearingDetailCard < Base
      attr_reader :application

      def initialize(application)
        @group = 'about_case'
        @section = 'hearing_detail'
        @application = application
        super()
      end

      def row_data
        base_rows + court_type_rows
      end

      private

      # rubocop:disable Metrics/MethodLength
      def base_rows
        [
          {
            head_key: 'next_hearing_date',
            text: application.next_hearing_date.to_fs(:stamp),
          },
          {
            head_key: 'plea',
            text: I18n.t("plea_description.#{application.plea}", scope: i18n_scope),
          },
          {
            head_key: 'court_type',
            text: I18n.t("court_type_description.#{application.court_type}", scope: i18n_scope),
          },
        ]
      end
      # rubocop:enable Metrics/MethodLength

      def i18n_scope
        @i18n_scope ||= 'prior_authority.steps.hearing_detail.edit'
      end

      def court_type_rows
        if application.youth_court_applicable?
          youth_court_rows
        elsif application.psychiatric_liaison_applicable?
          psychiatric_liaison_rows
        else
          []
        end
      end

      def youth_court_rows
        [
          {
            head_key: 'youth_court',
            text: I18n.t("generic.#{application.youth_court}"),
          },
        ]
      end

      def psychiatric_liaison_rows
        [
          {
            head_key: 'psychiatric_liaison',
            text: I18n.t("generic.#{application.psychiatric_liaison}"),
          },
          *psychiatric_liaison_reason_not_row,
        ]
      end

      def psychiatric_liaison_reason_not_row
        return [] if application.psychiatric_liaison?

        [
          {
            head_key: 'psychiatric_liaison_reason_not',
            text: application.psychiatric_liaison_reason_not,
          },
        ]
      end
    end
  end
end
