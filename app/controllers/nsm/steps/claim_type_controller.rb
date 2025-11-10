module Nsm
  module Steps
    class ClaimTypeController < ApplicationController
      def new
        @form_object = ClaimTypeForm.new
        render :edit
      end

      def edit
        @form_object = ClaimTypeForm.new(initial_params)
      end

      def update
        @form_object = ClaimTypeForm.new(form_params)
        case @form_object.claim_type
        when ClaimType::NON_STANDARD_MAGISTRATE
          update_claim unless new_record?
          redirect_to edit_nsm_steps_details_path(claim_id)
        when ClaimType::BREACH_OF_INJUNCTION
          update_claim unless new_record?
          redirect_to edit_nsm_steps_boi_details_path(claim_id)
        when ClaimType::SUPPLEMENTAL
          redirect_to nsm_applications_steps_supplemental_claim_path(claim_id:)
        else
          redirect_to new_nsm_steps_claim_type_path, flash: { alert: t('.no_type_selected') }
        end
      end

      private

      def initial_params
        new_record? ? form_params : { claim_type: Claim.find(claim_id).claim_type }
      end

      def form_params
        params
          .fetch(ClaimTypeForm.model_name.singular, {})
          .permit(ClaimTypeForm.attribute_names)
      end

      def claim_id
        @claim_id ||= params[:id] || StartPage::NEW_RECORD
      end

      def new_record?
        claim_id == StartPage::NEW_RECORD
      end

      def update_claim
        claim = Claim.find(claim_id)
        claim.update!(form_params)
      end
    end
  end
end
