module Tasks
  class CaseDisposal < BaseTask
    def path
      edit_steps_case_disposal_path
    end

    def not_applicable?
      false
    end

    def can_start?
      fulfilled?(CaseDetails)
    end

    def completed?
      application.plea.present?
    end
  end
end
