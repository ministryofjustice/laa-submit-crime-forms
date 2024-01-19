module PriorAuthority
  module Steps
    class PrisonLawController < BaseController
      def edit
        @form_object = PrisonLawForm.build(
          current_application
        )
      end

      def update
        update_and_advance(PrisonLawForm, as:, after_commit_redirect_path:)
      end

      private

      def as
        :prison_law
      end
    end
  end
end
