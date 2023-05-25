module Tasks
  class CaseDetails < BaseTask
    def path
      edit_steps_case_details_path
    end

    def not_applicable?
      false
    end

    def can_start?
      fulfilled?(FirmDetails)
    end

    def completed?
      Steps::CaseDetailsForm.new(application:).valid?
    end
  end
end
