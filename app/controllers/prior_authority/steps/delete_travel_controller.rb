module PriorAuthority
  module Steps
    class DeleteTravelController < BaseController
      def edit
        @form_object = DeleteTravelForm.build(
          current_application
        )
      end

      def update
        update_and_advance(DeleteTravelForm, as:, after_commit_redirect_path:)
      end

      private

      def as
        :delete_travel
      end
    end
  end
end
