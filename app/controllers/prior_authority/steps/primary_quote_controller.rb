module PriorAuthority
  module Steps
    class PrimaryQuoteController < BaseController
      def edit
        @form_object = PrimaryQuoteForm.build(
          primary_quote,
          application: current_application
        )
      end

      def update
        record = primary_quote
        update_and_advance(PrimaryQuoteForm, as:, after_commit_redirect_path:, record:)
      end

      private

      def primary_quote
        current_application.primary_quote || current_application.build_primary_quote
      end

      def as
        :primary_quote
      end

      def additional_permitted_params
        [:service_type_suggestion]
      end
    end
  end
end
