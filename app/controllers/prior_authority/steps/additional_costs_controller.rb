module PriorAuthority
  module Steps
    class AdditionalCostsController < BaseController
      def edit
        @form_object = AdditionalCosts::OverviewForm.build(
          current_application
        )
        # We never want 'yes' to be pre-selected as it makes for confusing UX.
        # 'No' being pre-selected is fine otherwise users have to re-enter the same information
        # every time they come back to this screen.
        @form_object.additional_costs_still_to_add = nil if @form_object.additional_costs_still_to_add
      end

      def update
        update_and_advance(AdditionalCosts::OverviewForm, as:, after_commit_redirect_path:)
      end

      private

      def as
        :additional_costs
      end
    end
  end
end
