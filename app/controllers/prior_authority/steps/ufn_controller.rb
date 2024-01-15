module PriorAuthority
  module Steps
    class UfnController < BaseController
      def edit
        @form_object = UfnForm.build(
          current_application
        )
      end

      def update
        update_and_advance(UfnForm, as: :ufn)
      end

      private

      def decision_tree_class
        Decisions::DecisionTree
      end
    end
  end
end
