module PriorAuthority
  module Steps
    class OfficeCodeController < PriorAuthority::Steps::BaseController
      def edit
        @form_object = OfficeCodeForm.build(
          current_application
        )
      end

      def update
        update_and_advance(OfficeCodeForm, as:, after_commit_redirect_path:)
      end

      private

      def as
        :pa_office_code
      end
    end
  end
end
