# frozen_string_literal: true

module CheckAnswers
  class DisbursementCostsCard < Base
    attr_reader :disbursement_type_form

    def initialize(_claim)
      @group = 'about_claim'
      @section = 'disbursements'
    end
  end
end
