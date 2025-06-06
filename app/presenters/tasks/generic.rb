module Tasks
  class Generic
    include Routing

    attr_accessor :application, :task_statuses

    def initialize(application:, task_statuses: TaskList::TaskStatus.new)
      @application = application
      @task_statuses = task_statuses
    end

    def self.build(name, **)
      parts = name.to_s.split('/')
      namespace = parts.first.camelize if parts.count == 2
      class_name = "#{namespace}::Tasks::#{parts.last.split('.').first.camelize}"
      if const_defined?(class_name)
        class_name.constantize.new(**)
      else
        new(**)
      end
    end

    def fulfilled?(task_class)
      task_statuses.status(task_class:, application:).completed?
    end

    # Used by the `Routing` module to build the urls
    def default_url_options
      { id: application }
    end

    def status
      task_statuses.self_status(task: self)
    end

    def current_status
      return TaskStatus::NOT_APPLICABLE if not_applicable?
      return TaskStatus::UNREACHABLE unless in_progress? || can_start?
      return TaskStatus::NOT_STARTED unless in_progress?
      return TaskStatus::COMPLETED if completed?

      TaskStatus::IN_PROGRESS
    end

    def in_progress?
      application.viewed_steps.include?(step_name)
    end

    def not_applicable?
      false
    end

    def path
      form_class = self.class::PREVIOUS_TASKS::FORM
      destination = self.class::DECISION_TREE.new(
        form_class.new(application:, record:),
        as: self.class::PREVIOUS_STEP_NAME,
      ).destination
      url_for(**destination, only_path: true)
    end

    def step_name
      path.split('/').reject { _1.include?('-') }.last
    end

    def can_start?
      previous_tasks.all? { |task| fulfilled?(task) } ||
        application.sent_back?
    end

    def completed?(rec = record, form = associated_form)
      form = form.build(rec, application:)
      form.validate
      form.valid?
    end

    private

    def previous_tasks
      Array(self.class::PREVIOUS_TASKS)
    end

    def record
      application
    end

    def associated_form
      self.class.try(:new, application:).try(:form) || self.class::FORM
    end
  end
end
