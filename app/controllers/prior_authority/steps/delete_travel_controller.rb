module PriorAuthority
  module Steps
    class DeleteTravelController < BaseController
      def edit
        @form_object = DeleteTravelForm.build(
          record,
          application: current_application
        )
      end

      def update
        update_and_advance(DeleteTravelForm, as:, after_commit_redirect_path:, record:)
      end

      private

      def record
        current_application.primary_quote
      end

      def as
        :delete_travel
      end
    end
  end
end
