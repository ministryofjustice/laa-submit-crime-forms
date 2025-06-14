# frozen_string_literal: true

module PriorAuthority
  module CheckAnswers
    class CaseContactCard < Base
      attr_reader :application

      def initialize(application)
        @group = 'contact_details'
        @section = 'case_contact'
        @application = application
        super()
      end

      def row_data
        base_rows
      end

      def base_rows
        [
          {
            head_key: 'contact_details',
            text: contact_details_html,
          },
          {
            head_key: 'firm_details',
            text: firm_details_html,
          },
        ]
      end

      def completed?
        PriorAuthority::Tasks::CaseContact.new(application:).completed?
      end

      private

      delegate :solicitor, :firm_office, to: :application

      def contact_details_html
        contact_details_html = [
          check_missing(solicitor.contact_full_name),
          check_missing(solicitor.contact_email)
        ].compact.join('<br>')

        sanitize(contact_details_html, tags: %w[br strong])
      end

      def firm_details_html
        firm_details_html = [
          check_missing(firm_office.name),
          check_missing(application.office_code)
        ].compact.join('<br>')

        sanitize(firm_details_html, tags: %w[br strong])
      end
    end
  end
end
