module Nsm
  module Steps
    class EqualityController < Nsm::Steps::BaseController
      def edit
        @form_object = AnswerEqualityForm.build(
          current_application
        )
      end

      def update
        update_and_advance(AnswerEqualityForm, as: :equality)
      end

      private

      def decision_tree_class
        Decisions::NsmDecisionTree
      end

      def additional_permitted_params
        [:answer_equality]
      end
    end
  end
end
