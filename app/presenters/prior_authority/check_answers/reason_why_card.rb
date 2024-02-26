# frozen_string_literal: true

module PriorAuthority
  module CheckAnswers
    class ReasonWhyCard < Base
      attr_reader :application

      def initialize(application)
        @group = 'about_request'
        @section = 'reason_why'
        @application = application
        super()
      end

      def row_data
        base_rows
      end

      def base_rows
        [
          {
            head_key: 'reason_why',
            text: simple_format(application.reason_why),
          },
          {
            head_key: 'supporting_documents',
            text: supporting_documents,
          },
        ]
      end

      private

      def supporting_documents
        @supporting_documents ||= if application.supporting_documents.none?
                                    I18n.t('prior_authority.generic.none')
                                  else
                                    text = application.supporting_documents.map(&:file_name).join('<br>')
                                    sanitize(text, tags: %w[br])
                                  end
      end
    end
  end
end
