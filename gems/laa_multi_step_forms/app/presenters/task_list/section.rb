module TaskList
  class Section < BaseRenderer
    attr_reader :tasks, :index, :show_index

    def initialize(application, name:, tasks:, index:, show_index: true)
      super(application, name:)

      @tasks = tasks
      @index = index
      @show_index = show_index
    end

    def render
      tag.li do
        safe_join(
          [section_header, section_tasks]
        )
      end
    end

    def items
      @items ||= tasks.map do |name|
        name = name.call(application) if name.respond_to?(:call)

        Task.new(application, name:)
      end
    end

    private

    def section_header
      tag.h2 class: 'moj-task-list__section' do
        if show_index
          tag.span class: 'moj-task-list__section-number' do
            "#{index}."
          end.concat t!("tasklist.heading.#{name}")
        else
          t!("tasklist.heading.#{name}")
        end
      end
    end

    def section_tasks
      tag.ul class: 'moj-task-list__items' do
        safe_join(
          items.map(&:render)
        )
      end
    end
  end
end
