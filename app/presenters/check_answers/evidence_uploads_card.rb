# frozen_string_literal: true

module CheckAnswers
  class EvidenceUploadsCard < Base
    def initialize(_claim)
      @group = 'supporting_evidence'
      @section = 'evidence_upload'
    end

    # TO DO: This should go to the evidence uploads page but it's not made yet
    def route_path
      'firm_details'
    end
  end
end
