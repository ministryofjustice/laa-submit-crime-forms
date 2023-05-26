module Tasks
  class CaseDetails < BaseTask
    def path
      edit_steps_case_details_path(application)
    end

    def not_applicable?
      false
    end

    def can_start?
      fulfilled?(FirmDetails)
    end

    def completed?
      Steps::CaseDetailsForm.build(application).valid?
    end
  end
end
