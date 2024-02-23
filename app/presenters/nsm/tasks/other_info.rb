module Nsm
  module Tasks
    class OtherInfo < Base
      FORM = Nsm::Steps::OtherInfoForm

      def can_start?
        application.navigation_stack.include?(nsm_steps_cost_summary_path(application))
      end

      def path
        edit_nsm_steps_other_info_path(application)
      end
    end
  end
end
