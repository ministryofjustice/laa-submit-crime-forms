module Tasks
  class FirmDetails < Generic
    FORM = Steps::FirmDetailsForm

    def path
      edit_steps_firm_details_path(application)
    end

    def can_start?
      true
    end
  end
end
