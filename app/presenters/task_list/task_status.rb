module TaskList
  class TaskStatus
    def status(task_class:, application:)
      statuses[task_class] ||=
        task_class.new(application: application, task_statuses: self).current_status
    end

    def self_status(task:)
      statuses[task.class] ||= task.current_status
    end

    private

    def statuses
      @statuses ||= {}
    end
  end
end
