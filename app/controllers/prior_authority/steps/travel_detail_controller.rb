module PriorAuthority
  module Steps
    class TravelDetailController < BaseController
      def edit
        @form_object = TravelDetailForm.build(
          current_application
        )
      end

      def update
        update_and_advance(TravelDetailForm, as:, after_commit_redirect_path:)
      end

      private

      def as
        :travel_detail
      end
    end
  end
end
