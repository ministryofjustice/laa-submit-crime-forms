module Nsm
  module Steps
    class ClaimTypeController < ApplicationController
      def edit
        @form_object = ClaimTypeForm.new
      end

      def update
        @form_object = ClaimTypeForm.new(permitted_params)
        case @form_object.claim_type
        when ClaimType::NON_STANDARD_MAGISTRATE
          redirect_to new_nsm_steps_details_path(StartPage::NEW_RECORD)
        when ClaimType::BREACH_OF_INJUNCTION
          redirect_to new_nsm_steps_boi_details_path(StartPage::NEW_RECORD)
        when ClaimType::SUPPLEMENTAL
          redirect_to nsm_applications_steps_supplemental_claim_path
        else
          redirect_to nsm_applications_steps_claim_type_path, flash: { alert: t('.no_type_selected') }
        end
      end

      private

      def permitted_params
        params
          .fetch(ClaimTypeForm.model_name.singular, {})
          .permit(ClaimTypeForm.attribute_names)
      end
    end
  end
end
