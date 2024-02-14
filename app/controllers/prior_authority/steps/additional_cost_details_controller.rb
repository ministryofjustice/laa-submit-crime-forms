module PriorAuthority
  module Steps
    class AdditionalCostDetailsController < BaseController
      include AddAnotherMethods

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
    end
  end
end
