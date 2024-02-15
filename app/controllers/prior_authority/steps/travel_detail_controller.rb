module PriorAuthority
  module Steps
    class TravelDetailController < BaseController
      def edit
        @form_object = TravelDetailForm.build(
          record,
          application: current_application
        )
      end

      def update
        update_and_advance(TravelDetailForm, as:, after_commit_redirect_path:, record:)
      end

      def reload
        render :edit
      end

      private

      def record
        current_application.primary_quote
      end

      def as
        :travel_detail
      end
    end
  end
end
