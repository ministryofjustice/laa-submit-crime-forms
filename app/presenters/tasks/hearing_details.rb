module Tasks
  class HearingDetails < Generic
    PREVIOUS_TASK = CaseDisposal
    FORM = Steps::HearingDetailsForm

    def path
      edit_steps_hearing_details_path(application)
    end
  end
end
