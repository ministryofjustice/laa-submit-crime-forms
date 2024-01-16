module PriorAuthority
  module Steps
    class CaseContactController < BaseController
      def edit
        @form_object = CaseContactForm.build(
          current_application
        )
      end

      def update
        update_and_advance(CaseContactForm, as: :case_contact)
      end

      private

      def decision_tree_class
        Decisions::DecisionTree
      end

      def additional_permitted_params
        [
          firm_office_attributes: PriorAuthority::Steps::CaseContact::FirmDetailForm.attribute_names,
        ]
      end
    end
  end
end
