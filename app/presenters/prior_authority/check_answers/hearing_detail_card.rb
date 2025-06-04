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

      def completed?
        PriorAuthority::Tasks::CaseAndHearingDetail.new(application:).hearing_detail_completed?
      end

      def change_action
        helper = Rails.application.routes.url_helpers
        helper.url_for(controller: "prior_authority/steps/#{section}",
                       action: request_method,
                       application_id: application.id,
                       only_path: true)
      end

      private

      def base_rows
        [
          {
            head_key: 'next_hearing_date',
            text: check_missing(next_hearing_date),
          },
          {
            head_key: 'plea',
            text: check_missing(application.plea, I18n.t("plea_description.#{application.plea}", scope: i18n_scope)),
          },
          {
            head_key: 'court_type',
            text: check_missing(application.court_type,
                                I18n.t("court_type_description.#{application.court_type}", scope: i18n_scope)),
          },
        ]
      end

      def i18n_scope
        @i18n_scope ||= 'prior_authority.steps.hearing_detail.edit'
      end

      def next_hearing_date
        if application.next_hearing
          check_missing(application.next_hearing_date&.to_fs(:stamp))
        else
          I18n.t('generic.unknown')
        end
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
            text: check_missing(application.youth_court, I18n.t("generic.#{application.youth_court}")),
          },
        ]
      end

      def psychiatric_liaison_rows
        [
          {
            head_key: 'psychiatric_liaison',
            text: check_missing(application.psychiatric_liaison, I18n.t("generic.#{application.psychiatric_liaison}")),
          },
          *psychiatric_liaison_reason_not_row,
        ]
      end

      def psychiatric_liaison_reason_not_row
        return [] if application.psychiatric_liaison?

        [
          {
            head_key: 'psychiatric_liaison_reason_not',
            text: check_missing(application.psychiatric_liaison_reason_not,
                                simple_format(application.psychiatric_liaison_reason_not)),
          },
        ]
      end
    end
  end
end
