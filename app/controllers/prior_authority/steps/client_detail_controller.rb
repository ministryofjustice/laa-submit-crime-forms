module PriorAuthority
  module Steps
    class ClientDetailController < BaseController
      def edit
        @form_object = ClientDetailForm.build(
          current_application
        )
      end

      def update
        update_and_advance(ClientDetailForm, as:, after_commit_redirect_path:)
      end

      private

      def as
        :client_detail
      end
    end
  end
end
