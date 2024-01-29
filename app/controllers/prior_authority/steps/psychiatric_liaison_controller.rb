module PriorAuthority
  module Steps
    class PsychiatricLiaisonController < BaseController
      def edit
        @form_object = PsychiatricLiaisonForm.build(
          current_application
        )
      end

      def update
        update_and_advance(PsychiatricLiaisonForm, as:, after_commit_redirect_path:)
      end

      private

      def as
        :psychiatric_liaison
      end
    end
  end
end
