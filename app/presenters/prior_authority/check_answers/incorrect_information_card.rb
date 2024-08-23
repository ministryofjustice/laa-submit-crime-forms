# frozen_string_literal: true

module PriorAuthority
  module CheckAnswers
    class IncorrectInformationCard < Base
      attr_reader :incorrect_information, :application

      def initialize(incorrect_information)
        @group = 'about_request'
        @section = 'incorrect_information'
        @incorrect_information = incorrect_information
        @application = incorrect_information.prior_authority_application
        super()
      end

      def title
        super(date: incorrect_information.requested_at.to_fs(:stamp))
      end

      def row_data
        [
          {
            head_key: 'information_requested',
            text: simple_format(incorrect_information.information_requested),
          },
          response,
        ].compact
      end

      private

      def response
        return nil if application.pending_incorrect_information == incorrect_information

        {
          head_key: 'information_supplied',
          text: translate_table_key(@section, 'details_amended', changes:),
        }
      end

      def changes
        change_strings.to_sentence.then { _1[0].upcase + _1[1..] }
      end

      def change_strings
        incorrect_information.sections_changed.map do |section|
          if section.starts_with?('alternative_quote')
            translate_table_key(@section, 'sections.alternative_quote', n: section.delete('alternative_quote_'))
          else
            translate_table_key(@section, "sections.#{section}")
          end
        end
      end
    end
  end
end
