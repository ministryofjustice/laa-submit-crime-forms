module Tasks
  class CaseDisposal < Generic
    PREVIOUS_TASK = CaseDetails

    def path
      edit_steps_case_disposal_path(application)
    end

    def completed?
      application.plea.present?
    end
  end
end
