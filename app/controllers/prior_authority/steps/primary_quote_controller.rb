module PriorAuthority
  module Steps
    class PrimaryQuoteController < BaseController
      def edit
        @form_object = PrimaryQuoteForm.build(
          application: current_application
        )
      end

      def update
        update_and_advance(PrimaryQuoteForm, as:, after_commit_redirect_path:)
      end

      private

      def as
        :primary_quote
      end
    end
  end
end
