# frozen_string_literal: true

module CheckAnswers
  class ClaimDetailsCard < Base
    attr_reader :claim_details_form

    KEY = 'claim_details'
    GROUP = 'about_claim'

    def initialize(claim)
      @claim_details_form = Steps::ClaimDetailsForm.build(claim)
      @group = GROUP
      @section = KEY
    end

    def route_path
      'claim_details'
    end
  end
end
