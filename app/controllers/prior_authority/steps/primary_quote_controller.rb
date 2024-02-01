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
        record = current_application.primary_quote || current_application.build_primary_quote
        record.service_type = record.custom_service_name if record.service_type == 'custom'
        record
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
