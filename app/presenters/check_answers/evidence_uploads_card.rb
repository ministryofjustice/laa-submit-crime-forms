# frozen_string_literal: true

module CheckAnswers
  class EvidenceUploadsCard < Base
    def initialize(_claim)
      @group = 'supporting_evidence'
      @section = 'firm_details'
    end
  end
end
