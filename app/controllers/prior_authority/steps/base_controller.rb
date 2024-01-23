module PriorAuthority
  module Steps
    class BaseController < ::Steps::BaseStepController
      include ApplicationHelper
      include CookieConcern

      layout 'prior_authority'

      before_action :set_default_cookies
      before_action :authenticate_provider!

      private

      def decision_tree_class
        Decisions::DecisionTree
      end

      def after_commit_redirect_path
        prior_authority_after_commit_path(id: current_application.id)
      end

      # :nocov:
      def as
        raise 'Implement in sub class'
      end
      # :nocov:
    end
  end
end
