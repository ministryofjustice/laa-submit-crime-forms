module Tasks
  class FirmDetails < Generic
    PREVIOUS_TASK = ClaimType
    FORM = Steps::FirmDetailsForm

    def path
      edit_steps_firm_details_path(application)
    end
  end
end
