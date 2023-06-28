module Tasks
  class WorkItems < Generic
    PREVIOUS_TASK = ClaimDetails
    FORM = Steps::WorkItemForm

    def path
      if application.work_items.count.positive?
        edit_steps_work_items_path(application)
      else
        edit_steps_work_item_path(id: application, work_item_id: "create_first")
      end
    end

    def in_progress?
      [
        edit_steps_work_items_path(application),
        edit_steps_work_item_path(id: application.id, work_item_id: '')
      ].any? do |path|
        application.navigation_stack.any? { |stack| stack.start_with?(path) }
      end
    end

    def completed?
      application.work_items.any? && application.work_items.all? do |record|
        super(record)
      end
    end
  end
end
