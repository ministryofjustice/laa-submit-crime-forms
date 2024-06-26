module TaskList
  class Collection < SimpleDelegator
    attr_reader :view, :application, :show_index

    delegate :size, to: :all_tasks
    delegate :tag, :safe_join, to: :view

    def initialize(view, application:, show_index: false)
      @view = view
      @application = application
      @show_index = show_index

      super(collection)
    end

    def render
      tag.ol class: 'govuk-task-list' do
        safe_join(map(&:render))
      end
    end

    def completed
      all_tasks.select(&:completed?)
    end

    private

    def all_tasks
      map(&:items).flatten
    end

    def collection
      sections.map.with_index(1) do |(name, tasks), index|
        Section.new(
          application,
          name: name,
          tasks: tasks,
          index: show_index ? index : nil,
          task_statuses: task_statuses
        )
      end
    end

    def sections
      raise 'implement SECTIONS, in subclasses' unless self.class.const_defined?(:SECTIONS)

      self.class::SECTIONS
    end

    def task_statuses
      @task_statuses ||= TaskStatus.new
    end
  end
end
