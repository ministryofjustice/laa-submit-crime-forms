module Nsm
  module Steps
    class OfficeAreaController < Nsm::Steps::BaseController
      def edit
        @form_object = OfficeAreaForm.build(
          current_application
        )
      end

      def update
        update_and_advance(OfficeAreaForm, as: :office_area)
      end

      private

      def decision_tree_class
        Decisions::DecisionTree
      end
    end
  end
end
