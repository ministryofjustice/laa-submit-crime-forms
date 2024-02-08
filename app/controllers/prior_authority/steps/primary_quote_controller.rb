module PriorAuthority
  module Steps
    class PrimaryQuoteController < BaseController
      before_action :set_service_type

      def edit
        @form_object = PrimaryQuoteForm.build(
          record,
          application: current_application
        )
      end

      def update
        update_and_advance(PrimaryQuoteForm, as:, after_commit_redirect_path:, record:)
      end

      private

      def record
        current_application.primary_quote || current_application.build_primary_quote
      end

      def as
        :primary_quote
      end

      def additional_permitted_params
        %i[service_type_suggestion service_type custom_service_name]
      end

      def set_service_type
        return unless current_application.service_type == 'custom'

        current_application.service_type = current_application.custom_service_name
      end
    end
  end
end
