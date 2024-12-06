module Nsm
  module Tasks
    class OtherInfo < Base
      FORM = Nsm::Steps::OtherInfoForm

      def can_start?
        application.viewed_steps.include?('cost_summary')
      end

      def path
        edit_nsm_steps_other_info_path(application)
      end
    end
  end
end
