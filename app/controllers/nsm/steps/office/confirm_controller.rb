module Steps
  module Office
    class ConfirmController < Steps::BaseStepController
      skip_before_action :check_application_presence

      def edit
        @form_object = ConfirmForm.new
      end

      def update
        update_and_advance(ConfirmForm, as: :confirm_office)
      end

      private

      def decision_tree_class
        Decisions::OfficeDecisionTree
      end

      def skip_stack
        true
      end
    end
  end
end
