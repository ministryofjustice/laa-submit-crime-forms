# frozen_string_literal: true

module CheckAnswers
  class EvidenceUploadsCard < Base
    attr_reader :claim

    def initialize(claim)
      @group = 'supporting_evidence'
      @section = 'supporting_evidence'
      @claim = claim
    end

    def row_data
      [
        {
          head_key: 'send_by_post',
          text: check_missing(!claim.send_by_post.nil?) do
            (claim.send_by_post ? YesNoAnswer::YES : YesNoAnswer::NO).to_s.capitalize
          end,
        }
      ] + supporting_evidence_rows
    end

    private

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
