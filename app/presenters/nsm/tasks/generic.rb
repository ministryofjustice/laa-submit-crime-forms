module Nsm
  module Tasks
    class Generic < ::Tasks::BaseTask
      def not_applicable?
        false
      end

      def path
        form_class = self.class::PREVIOUS_TASK::FORM
        destination = Decisions::DecisionTree.new(
          form_class.new(application:, record:),
          as: self.class::PREVIOUS_STEP_NAME,
        ).destination

        url_for(**destination, only_path: true)
      end

      def can_start?
        fulfilled?(self.class::PREVIOUS_TASK)
      end

      def completed?(rec = record, form = associated_form)
        form.build(rec, application:).valid?
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
end
