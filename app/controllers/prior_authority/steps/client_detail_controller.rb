module PriorAuthority
  module Steps
    class ClientDetailController < BaseController
      include ApplicationHelper
      include CookieConcern
      layout 'prior_authority'

      before_action :set_default_cookies, :ensure_client

      def edit
        @form_object = ClientDetailForm.build(
          client,
          application: current_application
        )
      end

      def update
        update_and_advance(ClientDetailForm, as: :client_detail, record: client)
      end

      private

      def decision_tree_class
        Decisions::DecisionTree
      end

      def client
        @client ||=
          if current_application.client.nil?
            current_application.build_client(id: SecureRandom.uuid)
          else
            current_application.client
          end
      end

      def ensure_client
        client || redirect_to(edit_prior_authority_steps_case_contact_path(current_application))
      end
    end
  end
end
