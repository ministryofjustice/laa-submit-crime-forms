# frozen_string_literal: true

module CheckAnswers
  class ClaimJustificationCard < Base
    attr_reader :reason_for_claim

    def initialize(claim)
      @reason_for_claim_form = Steps::ReasonForClaimForm.build(claim)
      @group = 'about_claim'
      @section = 'claim_justification'
    end

    def route_path
      'reason_for_claim'
    end
  end
end
