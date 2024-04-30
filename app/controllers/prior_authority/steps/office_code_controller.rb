module PriorAuthority
  module Steps
    class OfficeCodeController < PriorAuthority::Steps::BaseController
      def edit
        @form_object = OfficeCodeForm.build(
          current_application
        )
      end

      def update
        update_and_advance(OfficeCodeForm, as: :pa_office_code)
      end

      private

      def decision_tree_class
        Decisions::DecisionTree
      end
    end
  end
end
