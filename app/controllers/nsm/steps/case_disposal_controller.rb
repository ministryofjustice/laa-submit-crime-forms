module Nsm
  module Steps
    class CaseDisposalController < Nsm::Steps::BaseController
      def edit
        @form_object = CaseDisposalForm.build(
          current_application
        )
      end

      def update
        update_and_advance(CaseDisposalForm, as: :case_disposal)
      end
    end
  end
end
