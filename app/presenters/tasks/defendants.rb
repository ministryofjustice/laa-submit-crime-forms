module Tasks
  class Defendants < Generic
    PREVIOUS_TASK = FirmDetails
    FORM = Steps::DefendantDetailsForm

    def path
      case application.defendants.count
      when 0
        defendant = application.defendants.create
        edit_steps_defendant_details_path(id: application.id, defendant_id: defendant.id)
      when 1
        defendant = application.defendants.first
        edit_steps_defendant_details_path(id: application.id, defendant_id: defendant.id)
      else
        edit_steps_defendant_summary_path(application)
      end
    end

    def in_progress?
      [
        edit_steps_defendant_summary_path(application),
        edit_steps_defendant_details_path(id: application.id, defendant_id: '')
      ].any? do |path|
        application.navigation_stack.any? { |stack| stack.start_with?(path) }
      end
    end

    def completed?
      application.defendants.any? && application.defendants.all? do |record|
        super(record)
      end
    end
  end
end
