# frozen_string_literal: true

module PriorAuthority
  module CheckAnswers
    class NextHearingCard < Base
      attr_reader :application

      def initialize(application)
        @group = 'about_case'
        @section = 'next_hearing'
        @application = application
        super()
      end

      def row_data
        base_rows
      end

      private

      def base_rows
        [
          {
            head_key: 'next_hearing_date',
            text: next_hearing_date,
          },
        ]
      end

      def next_hearing_date
        if application.next_hearing
          application.next_hearing_date.to_fs(:stamp)
        else
          I18n.t('generic.unknown')
        end
      end
    end
  end
end
