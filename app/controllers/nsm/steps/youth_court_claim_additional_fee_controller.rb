module Nsm
  module Steps
    class YouthCourtClaimAdditionalFeeController < Nsm::Steps::BaseController
      def edit
        @form_object = YouthCourtClaimAdditionalFeeForm.build(
          current_application
        )
      end

      def update
        update_and_advance(YouthCourtClaimAdditionalFeeForm, as: :youth_court_claim_additional_fee)
      end
    end
  end
end
