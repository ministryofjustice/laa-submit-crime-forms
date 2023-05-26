module Tasks
  class FirmDetails < BaseTask
    def path
      edit_steps_firm_details_path(application)
    end

    def not_applicable?
      false
    end

    def can_start?
      true
    end

    def completed?
      Steps::FirmDetailsForm.build(application).valid?
    end
  end
end
