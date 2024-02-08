module PriorAuthority
  module Steps
    class ServiceCostController < BaseController
      def edit
        @form_object = ServiceCostForm.build(
          current_application.primary_quote,
          application: current_application
        )
      end

      def update
        record = current_application.primary_quote
        update_and_advance(ServiceCostForm, as:, after_commit_redirect_path:, record:)
      end

      private

      def as
        :service_cost
      end

      def additional_permitted_params
        [:prior_authority_granted]
      end
    end
  end
end
