# frozen_string_literal: true

module CheckAnswers
  class EvidenceUploadsCard < Base
    def initialize(_claim)
      @group = 'supporting_evidence'
      @section = 'supporting_evidence'
    end
  end
end
