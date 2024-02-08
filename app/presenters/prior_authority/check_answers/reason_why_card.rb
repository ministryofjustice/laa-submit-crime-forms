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
            text: application.reason_why,
          },
          {
            head_key: 'supporting_documents',
            text: supporting_documents,
          },
        ]
      end

      private

      def supporting_documents
        return @supporting_documents if @supporting_documents

        @supporting_documents = application.supporting_documents.map(&:file_name).join('<br>')
        @supporting_documents = sanitize(supporting_documents, tags: %w[br])
      end
    end
  end
end
