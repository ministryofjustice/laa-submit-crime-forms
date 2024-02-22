module Nsm
  module Steps
    class EqualityQuestionsController < Nsm::Steps::BaseController
      def edit
        @form_object = EqualityQuestionsForm.build(
          current_application
        )
      end

      def update
        update_and_advance(EqualityQuestionsForm, as: :equality_questions)
      end

      private

      def decision_tree_class
        Decisions::NsmDecisionTree
      end
    end
  end
end
