module PriorAuthority
  module Steps
    class ClientDetailController < BaseController
      include ApplicationHelper
      include CookieConcern
      layout 'prior_authority'

      before_action :set_default_cookies

      def edit
        @form_object = ClientDetailForm.build(
          current_application
        )
      end

      def update
        update_and_advance(ClientDetailForm, as: :client_detail)
      end

      private

      def decision_tree_class
        Decisions::DecisionTree
      end
    end
  end
end
