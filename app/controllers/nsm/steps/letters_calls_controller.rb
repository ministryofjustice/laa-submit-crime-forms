module Nsm
  module Steps
    class LettersCallsController < ::Steps::BaseStepController
      def edit
        @form_object = LettersCallsForm.build(
          current_application
        )
        @vat_included = current_application.firm_office.vat_registered == YesNoAnswer::YES.to_s
      end

      def update
        update_and_advance(LettersCallsForm, as: :letters_calls)
      end

      private

      def decision_tree_class
        Decisions::DecisionTree
      end

      def additional_permitted_params
        %i[apply_letters_uplift apply_calls_uplift]
      end
    end
  end
end
