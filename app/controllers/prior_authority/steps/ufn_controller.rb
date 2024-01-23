module PriorAuthority
  module Steps
    class UfnController < BaseController
      def edit
        @form_object = UfnForm.build(
          current_application
        )
      end

      def update
        update_and_advance(UfnForm, as:, after_commit_redirect_path:)
      end

      private

      def as
        :ufn
      end
    end
  end
end
