# frozen_string_literal: true
module CheckAnswers
  class EvidenceUploadsCard < Base
    KEY = 'evidence_upload'
    GROUP = 'supporting_evidence'

    def initialize(_claim)
      @group = GROUP
      @section = KEY
    end

    # TO DO: This should go to the evidence uploads page but it's not made yet
    def route_path
      'firm_details'
    end
  end
end
