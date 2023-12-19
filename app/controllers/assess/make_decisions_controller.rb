module Assess
  class MakeDecisionsController < Assess::ApplicationController
    def edit
      decision = MakeDecisionForm.new(claim:)
      render locals: { claim:, decision: }
    end

    # TODO: put some sort of permissions here for non supervisors?
    def update
      decision = MakeDecisionForm.new(claim:, **decision_params)
      if decision.save
        reference = BaseViewModel.build(:laa_reference, claim)
        success_notice = t(
          ".decision.#{decision.state}",
          ref: reference.laa_reference,
          url: assess_claim_claim_details_path(claim.id)
        )
        redirect_to assess_assessed_claims_path, flash: { success: success_notice }
      else
        render :edit, locals: { claim:, decision: }
      end
    end

    private

    def claim
      @claim ||= SubmittedClaim.find(params[:claim_id])
    end

    def decision_params
      params.require(:assess_make_decision_form).permit(
        :state, :partial_comment, :reject_comment
      ).merge(current_user:)
    end
  end
end
