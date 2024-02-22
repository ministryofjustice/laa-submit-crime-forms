module Nsm
  module Tasks
    class SolicitorDeclaration < Base
      PREVIOUS_TASKS = CheckAnswers
      FORM = Nsm::Steps::SolicitorDeclarationForm

      def path
        edit_nsm_steps_solicitor_declaration_path(application)
      end

      def status
        AlwaysDisabled.new(super)
      end
    end

    # used to stop the link rendering
    class AlwaysDisabled < SimpleDelegator
      def enabled?
        false
      end
    end
  end
end
