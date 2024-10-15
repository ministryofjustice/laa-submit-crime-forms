module PriorAuthority
  module Steps
    class AdditionalCostDetailsController < BaseController
      include AddAnotherMethods

      def destroy
        record.destroy
        new_path = if current_application.additional_costs.any?
                     edit_prior_authority_steps_additional_costs_path(current_application)
                   else
                     prior_authority_steps_primary_quote_summary_path(current_application)
                   end
        redirect_to new_path, flash: destroy_flash
      end

      private

      def build_form_object
        @form_object = AdditionalCosts::DetailForm.build(
          record,
          application: current_application
        )
      end

      def persist
        update_and_advance(AdditionalCosts::DetailForm, as:, after_commit_redirect_path:, record:)
      end

      def object_collection
        current_application.additional_costs
      end

      def as
        :additional_cost_details
      end

      def destroy_flash
        { success: t('.deleted') }
      end
    end
  end
end
