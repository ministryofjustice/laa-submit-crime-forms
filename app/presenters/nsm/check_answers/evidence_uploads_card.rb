# frozen_string_literal: true

module Nsm
  module CheckAnswers
    class EvidenceUploadsCard < Base
      attr_reader :claim

      def initialize(claim)
        @group = 'supporting_evidence'
        @section = 'supporting_evidence'
        @claim = claim
      end

      def row_data
        postal_evidence_row + supporting_evidence_rows
      end

      private

      def postal_evidence_row
        return [] unless FeatureFlags.postal_evidence.enabled?

        [
          {
            head_key: 'send_by_post',
            text: check_missing(!claim.send_by_post.nil?) do
              (claim.send_by_post ? YesNoAnswer::YES : YesNoAnswer::NO).to_s.capitalize
            end,
          }
        ]
      end

      def supporting_evidence_rows
        claim.supporting_evidence.map.with_index do |evidence, index|
          {
            head_key: 'supporting_evidence',
            text: evidence[:file_name],
            head_opts: { count: index + 1 }
          }
        end
      end
    end
  end
end
