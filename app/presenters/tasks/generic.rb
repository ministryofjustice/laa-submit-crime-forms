module Tasks
  class Generic < BaseTask
    def not_applicable?
      false
    end

    def can_start?
      fulfilled?(self.class::PREVIOUS_TASK)
    end

    def completed?(rec = record, form = associated_form)
      form.build(rec, application:).valid? : true
    end

    private

    def record
      application
    end

    def associated_form
      self.class::FORM
    end
  end
end
