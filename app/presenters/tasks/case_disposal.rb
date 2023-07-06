module Tasks
  class CaseDisposal < Generic
    PREVIOUS_TASK = HearingDetails
    FORM = Steps::CaseDisposalForm

    def path
      edit_steps_case_disposal_path(application)
    end
  end
end
