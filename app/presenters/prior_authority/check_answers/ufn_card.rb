# frozen_string_literal: true

module PriorAuthority
  module CheckAnswers
    class UfnCard < Base
      attr_reader :application

      def initialize(application)
        @group = 'application_detail'
        @section = 'ufn'
        @application = application
        super()
      end

      def row_data
        base_rows
      end

      def base_rows
        [
          {
            head_key: 'prison_law',
            text: check_missing(application.prison_law, I18n.t("generic.#{application.prison_law}")),
          },
          {
            head_key: 'laa_reference',
            text: check_missing(application.laa_reference),
          },
          {
            head_key: 'ufn',
            text: check_missing(application.ufn),
            actions: ufn_change_link,
          },
        ]
      end

      def ufn_change_link
        return [] if changes_forbidden?

        helper = Rails.application.routes.url_helpers

        [
          {
            href:  helper.url_for(controller: "prior_authority/steps/#{section}",
                                  action: request_method,
                                  application_id: application.id,
                                  only_path: true),
            visually_hidden_text: 'Change Unique file number',
          }
        ]
      end

      def title_actions
        []
      end

      def completed?
        PriorAuthority::Tasks::Ufn.new(application:).completed?
      end
    end
  end
end
