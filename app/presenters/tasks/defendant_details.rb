module Tasks
  class DefendantDetails < BaseTask
    def path
      edit_steps_defendant_details_path
    end

    def not_applicable?
      false
    end

    def can_start?
      fulfilled?(HearingDetails)
    end

    def completed?
      application.defendants.any? && Steps::DefendantsDetailsForm.new(application:).valid?
    end
  end
end
