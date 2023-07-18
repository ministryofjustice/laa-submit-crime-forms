module CheckAnswers
  class EvidenceUploadsCard < Base
    KEY = 'evidence_upload'.freeze
    GROUP = 'supporting_evidence'.freeze

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
