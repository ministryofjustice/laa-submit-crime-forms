module Nsm
  module Tasks
    class FirmDetails < Base
      PREVIOUS_TASKS = ClaimType
      FORM = Nsm::Steps::FirmDetailsForm

      def path
        edit_nsm_steps_firm_details_path(application)
      end

      def completed?
        super && application.office_code.present?
      end
    end
  end
end
