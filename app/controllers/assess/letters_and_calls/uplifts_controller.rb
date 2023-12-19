module Assess
  module LettersAndCalls
    class UpliftsController < Assess::ApplicationController
      def edit
        claim = SubmittedClaim.find(params[:claim_id])
        form = Uplift::LettersAndCallsForm.new(claim:)

        render locals: { claim:, form: }
      end

      def update
        claim = SubmittedClaim.find(params[:claim_id])
        form = Uplift::LettersAndCallsForm.new(claim:, **form_params)

        if form.save
          redirect_to assess_claim_adjustments_path(claim, anchor: 'letters-and-calls-tab'),
                      flash: { success: t('.uplift_removed') }
        else
          render :edit, locals: { claim:, form: }
        end
      end

      private

      def form_params
        params.require(:assess_uplift_letters_and_calls_form)
              .permit(:explanation)
              .merge(current_user:)
      end
    end
  end
end
