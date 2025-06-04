module PriorAuthority
  module Tasks
    class CaseContact < Base
      PREVIOUS_TASKS = Ufn
      FORM = PriorAuthority::Steps::CaseContactForm

      def path
        edit_prior_authority_steps_case_contact_path
      end

      def completed?
        super && application.office_code.present?
      end
    end
  end
end
