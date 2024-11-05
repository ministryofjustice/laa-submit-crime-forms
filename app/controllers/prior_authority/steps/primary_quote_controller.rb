module PriorAuthority
  module Steps
    class PrimaryQuoteController < BaseController
      def edit
        @services = count_services

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
        %i[service_type_autocomplete service_type_autocomplete_suggestion file_upload]
      end

      def count_services
        Rails.cache.fetch('service_counts', expires_in: 5.minutes) do
          counts = PriorAuthorityApplication
                   .where.not(service_type: [nil, ''])
                   .where('created_at > ?', 6.months.ago)
                   .group(:service_type)
                   .count

          values = PriorAuthority::QuoteServices.values.map do |service|
            [service.translated, counts.fetch(service.value.to_s, 0)]
          end

          values.sort_by { |_, count| -count }.to_h
        end
      end
    end
  end
end
