module PriorAuthority
  module Steps
    class BaseController < ::Steps::BaseStepController
      layout 'prior_authority'

      before_action :check_step_valid

      private

      def decision_tree_class
        Decisions::DecisionTree
      end

      def after_commit_redirect_path
        prior_authority_applications_path(anchor: 'drafts')
      end

      # :nocov:
      def as
        raise 'Implement in sub class'
      end
      # :nocov:

      def prune_navigation_stack
        # The default behaviour of prune_navigation_stack assumes linear completion of tasks
        # which doesn't apply to Prior Authority. So we do a noop instead.
      end

      def check_step_valid
        redirect_to prior_authority_application_path(current_application) unless step_valid?
      end

      def step_valid?
        current_application.draft? ||
          current_application.pre_draft? || (current_application.sent_back? && current_application.correction_needed?)
      end
    end
  end
end
