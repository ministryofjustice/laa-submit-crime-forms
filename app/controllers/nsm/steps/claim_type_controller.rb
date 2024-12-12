module Nsm
  module Steps
    class ClaimTypeController < Nsm::Steps::BaseController
      def edit
        @form_object = ClaimTypeForm.build(
          current_application
        )
      end

      def update
        update_and_advance(ClaimTypeForm, as: :claim_type)
      end
    end
  end
end
