module PriorAuthority
  module Steps
    class ClientDetailController < BaseController
      def edit
        @form_object = ClientDetailForm.build(
          defendant,
          application: current_application
        )
      end

      def update
        record = defendant
        update_and_advance(ClientDetailForm, as:, after_commit_redirect_path:, record:)
      end

      private

      def as
        :client_detail
      end

      def defendant
        current_application.defendant || current_application.build_defendant
      end
    end
  end
end
