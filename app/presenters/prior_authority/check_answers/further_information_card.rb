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

      def completed?
        PriorAuthority::Tasks::FurtherInformation.new(application:).completed?
      end

      private

      def supporting_documents
        @supporting_documents ||=
          if further_information.supporting_documents.none?
            I18n.t('prior_authority.generic.none')
          else
            links = further_information.supporting_documents.map do |document|
              govuk_link_to(document.file_name,
                            url_helper.download_path(document))
            end
            sanitize(links.join(tag.br), tags: %w[a br])
          end
      end

      def changes_forbidden?
        false
      end
    end
  end
end
