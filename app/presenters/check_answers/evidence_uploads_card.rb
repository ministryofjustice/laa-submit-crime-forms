# frozen_string_literal: true

module CheckAnswers
  class EvidenceUploadsCard < Base
    attr_reader :evidence_list

    def initialize(claim)
      @group = 'supporting_evidence'
      @section = 'supporting_evidence'
      @evidence_list = claim.supporting_evidence
    end

    def row_data
      evidence_list.map.with_index do |evidence, index|
        {
          head_key: 'supporting_evidence',
          text: evidence[:file_name],
          head_opts: { count: index + 1 }
        }
      end
    end
  end
end
