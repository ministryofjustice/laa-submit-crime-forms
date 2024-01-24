module PriorAuthority
  module Steps
    class HearingDetailController < BaseController
      def edit
        @form_object = HearingDetailForm.build(
          current_application
        )
      end

      def update
        update_and_advance(HearingDetailForm, as:, after_commit_redirect_path:)
      end

      private

      def as
        :hearing_detail
      end
    end
  end
end
