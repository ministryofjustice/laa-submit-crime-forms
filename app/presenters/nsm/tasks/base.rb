module Nsm
  module Tasks
    class Base < ::Tasks::Generic
      DECISION_TREE = Decisions::DecisionTree

      # If I complete sections A, B and C, then go back and change section A,
      # `prune_viewed_steps` will remove B and C from the stack.
      # The default behaviour in the gem is to mark B and C as not yet started,
      # even though we have actually completed them. The desired behaviour is
      # to mark B as in progress and C as 'Cannot start yet'.
      # To achieve this, we need to loosen the definition of `in_progress?`
      # to include "not in navigation stack but actually already complete",
      # and adjust the rest of the logic around it accordingly
      def current_status
        return TaskStatus::NOT_APPLICABLE if not_applicable?
        return TaskStatus::UNREACHABLE unless can_start? || previously_visited?
        return TaskStatus::NOT_STARTED unless in_progress?
        return TaskStatus::COMPLETED if fully_completed?

        TaskStatus::IN_PROGRESS
      end

      def in_progress?
        previously_visited? || completed?
      end

      def fully_completed?
        completed? && previously_visited?
      end

      def previously_visited?
        application.viewed_steps.include?(step_name)
      end

      def viewed_subsequent_step?
        application.viewed_steps.intersect?(Decisions::OrderedSteps.nsm_after(step_name))
      end
    end
  end
end
