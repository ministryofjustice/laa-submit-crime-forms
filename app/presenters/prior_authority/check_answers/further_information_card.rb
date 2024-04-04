# frozen_string_literal: true

module PriorAuthority
  module CheckAnswers
    class FurtherInformationCard < Base
      attr_reader :application, :further_information

      def initialize(application)
        @group = 'about_request'
        @section = 'further_information'
        @application = application
        @further_information = application.further_informations.order(:requested_at).last
        super()
      end

      def row_data
        base_rows
      end

      def base_rows
        [
          {
            head_key: 'information_requested',
            text: simple_format(further_information.information_requested),
          },
          {
            head_key: 'information_supplied',
            text: simple_format(further_information.information_supplied),
          },
          {
            head_key: 'supporting_documents',
            text: supporting_documents,
          },
        ]
      end

      private

      def supporting_documents
        @supporting_documents ||=
          if further_information.supporting_documents.none?
            I18n.t('prior_authority.generic.none')
          else
            text = further_information.supporting_documents.map(&:file_name).join('<br>')
            sanitize(text, tags: %w[br])
          end
      end
    end
  end
end
