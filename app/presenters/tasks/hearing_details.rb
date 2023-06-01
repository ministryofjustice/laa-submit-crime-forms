module Tasks
  class HearingDetails < Generic
    FORM = Steps::HearingDetailsForm

    def path
      edit_steps_hearing_details_path(application)
    end

    def can_start?
      application.plea.present?
    end
  end
end
