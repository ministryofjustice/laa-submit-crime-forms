module Steps
  module Office
    class SelectController < Steps::BaseStepController
      skip_before_action :check_application_presence

      def edit
        @form_object = SelectForm.new(
          record: current_provider
        )
      end

      def update
        update_and_advance(
          SelectForm, record: current_provider, as: :select_office
        )
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
