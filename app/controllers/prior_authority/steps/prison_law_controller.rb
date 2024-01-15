module PriorAuthority
  module Steps
    class PrisonLawController < BaseController
      def edit
        @form_object = PrisonLawForm.build(
          current_application
        )
      end

      def update
        update_and_advance(PrisonLawForm, as: :prison_law)
      end

      private

      def decision_tree_class
        Decisions::DecisionTree
      end
    end
  end
end
