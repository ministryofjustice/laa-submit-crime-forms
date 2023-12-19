module Assess
  class SendBacksController < Assess::ApplicationController
    def edit
      send_back = SendBackForm.new(claim:)
      render locals: { claim:, send_back:, defendant_name: }
    end

    # TODO: put some sort of permissions here for non supervisors?
    def update
      send_back = SendBackForm.new(claim:, **send_back_params)
      if send_back.save
        reference = BaseViewModel.build(:laa_reference, claim)
        success_notice = t(
          '.decision',
          ref: reference.laa_reference,
          url: assess_claim_claim_details_path(claim.id)
        )
        redirect_to assess_your_claims_path, flash: { success: success_notice }
      else
        render :edit, locals: { claim:, send_back:, defendant_name: }
      end
    end

    private

    def claim
      @claim ||= SubmittedClaim.find(params[:claim_id])
    end

    def defendant_name
      defendants = claim.data['defendants']
      main_defendant = defendants.detect { |defendant| defendant['main'] }
      main_defendant ? main_defendant['full_name'] : ''
    end

    def send_back_params
      params.require(:assess_send_back_form).permit(
        :state, :comment,
      ).merge(current_user:)
    end
  end
end
