module Tasks
  class Generic < BaseTask
    def not_applicable?
      false
    end

    def can_start?
      fulfilled?(self.class::PREVIOUS_TASK)
    end

    def completed?(rec = record)
      self.class::FORM.build(rec, application:).valid?
    end

    private

    def record
      application
    end
  end
end
