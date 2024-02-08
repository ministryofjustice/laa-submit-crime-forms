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

      # rubocop:disable Metrics/MethodLength
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
          },
        ]
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
