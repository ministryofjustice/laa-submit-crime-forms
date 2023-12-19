module Assess
  class AdjustmentsController < Assess::ApplicationController
    def show
      claim = SubmittedClaim.find(params[:claim_id])
      claim_summary = BaseViewModel.build(:claim_summary, claim)
      core_cost_summary = BaseViewModel.build(:core_cost_summary, claim)

      render locals: { claim:, claim_summary:, core_cost_summary: }
    end
  end
end
