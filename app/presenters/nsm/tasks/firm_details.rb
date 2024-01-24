module Nsm
  module Tasks
    class FirmDetails < ::Tasks::Generic
      PREVIOUS_TASK = ClaimType
      FORM = Nsm::Steps::FirmDetailsForm

      def path
        edit_nsm_steps_firm_details_path(application)
      end
    end
  end
end
