module Tasks
  class Generic < ::Tasks::BaseTask
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

    def can_start?
      previous_tasks.all? { |task| fulfilled?(task) }
    end

    def completed?(rec = record, form = associated_form)
      form.build(rec, application:).valid?
    end

    private

    def previous_tasks
      Array(self.class::PREVIOUS_TASKS)
    end

    def record
      application
    end

    def associated_form
      self.class::FORM
    end
  end
end
