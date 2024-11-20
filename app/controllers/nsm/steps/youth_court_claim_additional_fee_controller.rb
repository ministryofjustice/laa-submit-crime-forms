module Nsm
  module Steps
    class YouthCourtClaimAdditionalFeeController < Nsm::Steps::BaseController
      def edit
        @form_object = YouthCourtClaimAdditionalFeeForm.build(
          current_application
        )
      end

      def update
        # update_and_advance(YouthCourtClaimAdditionalFeeForm, as: :youth_court_claim_additional_fee)
      end

      private

      def decision_tree_class
        Decisions::DecisionTree
      end

      def additional_permitted_params
        [:youth_court_fee_claimed]
      end
    end
  end
end
