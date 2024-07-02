# frozen_string_literal: true

module PriorAuthority
  module CheckAnswers
    class CompactFurtherInformationCard < Base
      attr_reader :further_information

      def initialize(further_information, skip_links: false)
        @group = 'about_request'
        @section = 'compact_further_information'
        @further_information = further_information
        @skip_links = skip_links
        super()
      end

      def title
        super(date: further_information.created_at.to_fs(:stamp))
      end

      def row_data
        base_rows
      end

      def base_rows
        [
          {
            head_key: 'information_request',
            text: simple_format(further_information.information_requested),
          },
          {
            head_key: 'your_response',
            text: supporting_documents,
          },
        ]
      end

      private

      def supporting_documents
        links = further_information.supporting_documents.map do |document|
          if @skip_links
            document.file_name
          else
            govuk_link_to(document.file_name,
                          url_helper.prior_authority_download_path(document))
          end
        end
        response = simple_format(further_information.information_supplied)
        parts = [response] + links.flat_map { [tag.br, _1] }
        safe_join(parts)
      end
    end
  end
end
