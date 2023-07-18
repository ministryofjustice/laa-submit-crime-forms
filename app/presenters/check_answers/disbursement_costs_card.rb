module CheckAnswers
  class DisbursementCostsCard < Base
    attr_reader :disbursement_type_form

    KEY = 'disbursement_costs'.freeze
    GROUP = 'about_claim'.freeze

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
