module TaskList
  class Collection < SimpleDelegator
    attr_reader :view, :application

    delegate :size, to: :all_tasks
    delegate :tag, :safe_join, to: :view

    def initialize(view, application:)
      @view = view
      @application = application

      super(collection)
    end

    def render
      tag.ol class: 'moj-task-list' do
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
      sections.map.with_index(1) do |(name, tasks), idx|
        Section.new(application, name: name, tasks: tasks, index: idx)
      end
    end

    def sections
      if self.class.const_defined?(:SECTIONS)
        self.class::SECTIONS
      else
        raise 'implement SECTIONS, in subclasses'
      end
    end
  end
end
