module PriorAuthority
  module Steps
    class BaseController < ::Steps::BaseStepController
      layout 'prior_authority'

      before_action :check_completed, only: :edit

      def edit; end

      private

      def decision_tree_class
        Decisions::PaDecisionTree
      end

      def after_commit_redirect_path
        prior_authority_root_path(anchor: 'drafts')
      end

      # :nocov:
      def as
        raise 'Implement in sub class'
      end
      # :nocov:

      def service
        Providers::Gatekeeper::PAA
      end

      def prune_navigation_stack
        # The default behaviour of prune_navigation_stack assumes linear completion of tasks
        # which doesn't apply to Prior Authority. So we do a noop instead.
      end

      def check_completed
        redirect_to prior_authority_steps_start_page_path(current_application) if answers_checked?
      end

      def answers_checked?
        PriorAuthority::Tasks::CheckAnswers.new(application: current_application).completed?
      end
    end
  end
end
