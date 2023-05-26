module Tasks
  class Defendants < BaseTask
    def path
      if application.defendants.count > 1
        edit_steps_defendant_summary_path(application)
      else
        edit_steps_defendant_details_path(application)
      end
    end

    def not_applicable?
      false
    end

    def can_start?
      fulfilled?(HearingDetails)
    end

    def in_progress?
      application.navigation_stack.intersect?([edit_steps_defendant_summary_path(application),
                                               edit_steps_defendant_details_path(application)])
    end

    def completed?
      application.defendants.any? && application.defendants.all? do |record|
        Steps::DefendantDetailsForm.build(record, application:).valid?
      end
    end
  end
end
