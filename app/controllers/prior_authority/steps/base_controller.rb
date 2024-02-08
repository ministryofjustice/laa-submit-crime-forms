module PriorAuthority
  module Steps
    class BaseController < ::Steps::BaseStepController
      layout 'prior_authority'

      private

      def decision_tree_class
        Decisions::DecisionTree
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
    end
  end
end
