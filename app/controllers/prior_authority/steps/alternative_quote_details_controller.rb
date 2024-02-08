module PriorAuthority
  module Steps
    class AlternativeQuoteDetailsController < AddAnotherController
      private

      def build_form_object
        @form_object = AlternativeQuotes::DetailForm.build(
          record,
          application: current_application
        )
      end

      def persist
        update_and_advance(AlternativeQuotes::DetailForm, as:, after_commit_redirect_path:, record:)
      end

      def object_collection
        current_application.alternative_quotes
      end

      def as
        :alternative_quote_details
      end
    end
  end
end
