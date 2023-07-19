# frozen_string_literal: true

module CheckAnswers
  class ClaimDetailsCard < Base
    attr_reader :claim_details_form

    def initialize(claim)
      @claim_details_form = Steps::ClaimDetailsForm.build(claim)
      @group = 'about_claim'
      @section = 'claim_details'
    end
  end
end
