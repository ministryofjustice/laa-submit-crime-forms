module TaskList
  class TaskStatus
    def status(task_class, application:)
      @status ||= {}
      @status[task_class] ||
        task_class.new(application: application, task_statuses: self).current_status
    end
  end
end
