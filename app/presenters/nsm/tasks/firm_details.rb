module Nsm
  module Tasks
    class FirmDetails < Generic
      PREVIOUS_TASK = ClaimType
      FORM = Nsm::Steps::FirmDetailsForm

      def path
        edit_steps_firm_details_path(application)
      end
    end
  end
end
