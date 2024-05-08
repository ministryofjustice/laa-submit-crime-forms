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
            text: I18n.t("generic.#{application.prison_law}"),
          },
          {
            head_key: 'laa_reference',
            text: application.laa_reference,
          },
          {
            head_key: 'ufn',
            text: application.ufn,
            actions: ufn_change_link,
          },
        ]
      end

      def ufn_change_link
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
    end
  end
end
