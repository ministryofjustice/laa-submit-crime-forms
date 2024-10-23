module Nsm
  module Steps
    class SolicitorDeclarationController < Nsm::Steps::BaseController
      def edit
        @form_object = SolicitorDeclarationForm.build(
          record,
          application: current_application
        )
      end

      def update
        update_and_advance(SolicitorDeclarationForm, as: :solicitor_declaration, record: record)
      end

      private

      def decision_tree_class
        Decisions::DecisionTree
      end

      def record
        current_application.sent_back? ? current_application.pending_further_information : current_application
      end

      def step_valid?
        current_application.draft? || current_application.sent_back?
      end
    end
  end
end
