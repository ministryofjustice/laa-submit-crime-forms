module TaskList
  class Task < BaseRenderer
    delegate :status, to: :task
    delegate :completed?, to: :status
    attr_reader :task_statuses

    def initialize(application, name:, task_statuses:)
      super(application, name:)

      @task_statuses = task_statuses
    end

    def render
      tag.li class: 'govuk-task-list__item govuk-task-list__item--with-link' do
        safe_join(
          [task_name, status_tag]
        )
      end
    end

    private

    def task_name
      tag.span class: 'app-task-list__task-name' do
        task_link
      end
    end

    def task_link
      if status.enabled?
        tag.a t!("tasklist.task.#{name}"), href: task.path, aria: { describedby: tag_id }
      else
        t!("tasklist.task.#{name}")
      end
    end

    def status_tag
      StatusTag.new(application, name:, status:).render
    end

    def task
      @task ||= Tasks::BaseTask.build(name, application:, task_statuses:)
    end
  end
end
