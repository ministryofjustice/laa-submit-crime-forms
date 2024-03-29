module Nsm
  module Steps
    class OtherInfoController < Nsm::Steps::BaseController
      def edit
        @form_object = OtherInfoForm.build(
          current_application
        )
      end

      def update
        update_and_advance(OtherInfoForm, as: :other_info)
      end

      private

      def decision_tree_class
        Decisions::DecisionTree
      end
    end
  end
end
