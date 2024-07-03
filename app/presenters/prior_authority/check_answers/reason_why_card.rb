# frozen_string_literal: true

module PriorAuthority
  module CheckAnswers
    class ReasonWhyCard < Base
      attr_reader :application

      def initialize(application, skip_links: false)
        @group = 'about_request'
        @section = 'reason_why'
        @application = application
        @skip_links = skip_links
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
                                    links = application.supporting_documents.map do |document|
                                      if @skip_links
                                        document.file_name
                                      else
                                        govuk_link_to(document.file_name,
                                                      url_helper.prior_authority_download_path(document))
                                      end
                                    end
                                    sanitize(links.join(tag.br), tags: %w[a br])
                                  end
      end
    end
  end
end
