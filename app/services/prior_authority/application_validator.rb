module PriorAuthority
  class ApplicationValidator
    def self.call(application)
      new(application).call
    end

    attr_reader :application

    def initialize(application)
      @application = application
    end

    def call
      tasks = extract_tasks
      incomplete_tasks = tasks.reject { _1.new(application:).completed? || _1 == PriorAuthority::Tasks::CheckAnswers }
      incomplete_tasks = incomplete_tasks.map do |task|
        task.new(application:).section_link
      end
      return if incomplete_tasks.blank?

      prefix = I18n.t('prior_authority.steps.check_answers.edit.incomplete_flash', count: incomplete_tasks.count)
      "#{prefix}: #{incomplete_tasks.join(',')}"
    end

    private

    def extract_tasks
      all_sections = PriorAuthority::StartPage::TaskList::SECTIONS + PriorAuthority::StartPage::PreTaskList::SECTIONS
      tasks = all_sections.pluck(1).flatten
      tasks.map { _1.slice! 'prior_authority/' }
      tasks.map { "PriorAuthority::Tasks::#{_1.camelize}".constantize }
    end
  end
end
