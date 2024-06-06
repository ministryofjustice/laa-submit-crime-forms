class SubmitToAppStore
  module PriorAuthority
    class QuotePayloadBuilder
      def initialize(application)
        @application = application
        @primary_quote = application.primary_quote
      end

      def payload
        @application.quotes.map do |quote|
          quote.as_json(only: ATTRIBUTES).merge(
            document: document(quote)
          ).merge(primary_quote_attributes)
        end
      end

      def document(quote)
        return nil unless quote.document

        quote.document.as_json(only: %i[file_name
                                        file_type
                                        file_size
                                        file_path
                                        document_type])
      end

      def primary_quote_attributes
        {
          cost_type: service_cost_form.cost_type,
          item_type: service_cost_form.item_type
        }
      end

      def service_cost_form
        @service_cost_form ||= ::PriorAuthority::Steps::ServiceCostForm.build(@primary_quote, application: @application)
      end

      ATTRIBUTES = %i[
        id
        travel_time
        travel_cost_per_hour
        travel_cost_reason
        contact_first_name
        contact_last_name
        organisation
        town
        postcode
        primary
        ordered_by_court
        related_to_post_mortem
        cost_per_hour
        cost_per_item
        items
        period
        additional_cost_list
        additional_cost_total
      ].freeze
    end
  end
end
