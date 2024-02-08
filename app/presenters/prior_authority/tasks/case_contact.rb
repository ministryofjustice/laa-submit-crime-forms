module PriorAuthority
  module Tasks
    class CaseContact < Base
      PREVIOUS_TASK = Ufn
      FORM = PriorAuthority::Steps::CaseContactForm

      def path
        edit_prior_authority_steps_case_contact_path
      end
    end
  end
end
