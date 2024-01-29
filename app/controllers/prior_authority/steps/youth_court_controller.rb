module PriorAuthority
  module Steps
    class YouthCourtController < BaseController
      def edit
        @form_object = YouthCourtForm.build(
          current_application
        )
      end

      def update
        update_and_advance(YouthCourtForm, as:, after_commit_redirect_path:)
      end

      private

      def as
        :youth_court
      end
    end
  end
end
