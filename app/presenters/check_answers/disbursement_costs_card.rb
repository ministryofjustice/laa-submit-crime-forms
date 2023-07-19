# frozen_string_literal: true
module CheckAnswers
  class DisbursementCostsCard < Base
    attr_reader :disbursement_type_form

    KEY = 'disbursement_costs'
    GROUP = 'about_claim'

    def initialize(_claim)
      # @disbursement_type_form = Steps::DisbursementTypeForm.build(claim)
      @group = GROUP
      @section = KEY
    end

    def route_path
      'disbursements'
    end
  end
end
