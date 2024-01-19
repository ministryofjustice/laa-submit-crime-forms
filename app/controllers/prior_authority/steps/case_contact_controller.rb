module PriorAuthority
  module Steps
    class CaseContactController < BaseController
      def edit
        @form_object = CaseContactForm.build(
          current_application
        )
      end

      def update
        update_and_advance(CaseContactForm, as:, after_commit_redirect_path:)
      end

      def additional_permitted_params
        [
          firm_office_attributes: PriorAuthority::Steps::CaseContact::FirmDetailForm.attribute_names,
          solicitor_attributes: PriorAuthority::Steps::CaseContact::SolicitorForm.attribute_names,
        ]
      end

      private

      def as
        :case_contact
      end
    end
  end
end
