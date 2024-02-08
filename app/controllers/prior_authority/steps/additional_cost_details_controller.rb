module PriorAuthority
  module Steps
    class AdditionalCostDetailsController < AddAnotherController
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

      def redirect_to_current_object
        redirect_to edit_prior_authority_steps_additional_cost_detail_path(current_application, record)
      end
    end
  end
end
