module PriorAuthority
  module Steps
    class NextHearingController < BaseController
      def edit
        @form_object = NextHearingForm.build(
          current_application
        )
      end

      def update
        update_and_advance(NextHearingForm, as:, after_commit_redirect_path:)
      end

      private

      def as
        :next_hearing
      end
    end
  end
end
