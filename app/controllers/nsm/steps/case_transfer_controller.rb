module Nsm
  module Steps
    class CaseTransferController < Nsm::Steps::BaseController
      def edit
        @form_object = CaseTransferForm.build(
          current_application
        )
      end

      def update
        update_and_advance(CaseTransferForm, as: :case_transfer)
      end
    end
  end
end
