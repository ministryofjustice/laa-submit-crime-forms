module Tasks
  class Generic < BaseTask
    def not_applicable?
      false
    end

    def can_start?
      fulfilled?(self.class::PREVIOUS_TASK)
    end

    def completed?(rec = record, form = self.class::FORM)
      form.build(rec, application:).valid?
    end

    private

    def record
      application
    end
  end
end
