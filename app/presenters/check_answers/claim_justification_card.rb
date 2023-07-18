module CheckAnswers
  class ClaimJustificationCard < Base
    attr_reader :reason_for_claim

    KEY = 'claim_justification'.freeze
    GROUP = 'about_claim'.freeze

    def initialize(claim)
      @reason_for_claim_form = Steps::ReasonForClaimForm.build(claim)
      @group = GROUP
      @section = KEY
    end

    def route_path
      'reason_for_claim'
    end
  end
end
