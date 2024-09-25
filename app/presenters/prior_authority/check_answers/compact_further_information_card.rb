# frozen_string_literal: true

module PriorAuthority
  module CheckAnswers
    class CompactFurtherInformationCard < Base
      include FurtherInformationPresentable

      def initialize(further_information, skip_links: false)
        @group = 'about_request'
        @section = 'compact_further_information'
        @further_information = further_information
        @skip_links = skip_links
        super()
      end
    end
  end
end
