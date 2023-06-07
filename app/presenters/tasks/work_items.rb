module Tasks
  class WorkItems < Generic
    PREVIOUS_TASK = HearingDetails
    FORM = Steps::WorkItemForm

    def path
      if application.work_items.count > 0
        edit_steps_work_items_path(application)
      else
        edit_steps_work_item_path(application)
      end
    end

    def in_progress?
      application.navigation_stack.intersect?([edit_steps_work_items_path(application),
                                               edit_steps_work_item_path(application)])
    end

    def completed?
      application.work_items.any? && application.work_items.all? do |record|
        super(record)
      end
    end
  end
end
