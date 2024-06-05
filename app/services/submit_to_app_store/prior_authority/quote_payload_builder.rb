class SubmitToAppStore
  module PriorAuthority
    class QuotePayloadBuilder
      def initialize(application)
        @application = application
      end

      def payload
        @application.quotes.map do |quote|
          quote.as_json(only: ATTRIBUTES).merge(
            cost_type: primary_cost_type,
            item_type: primary_item_type,
            document: document(quote)
          )
        end
      end

      def primary_cost_type
        form = ::PriorAuthority::Steps::ServiceCostForm.build(@application.primary_quote, application: @application)
        form.cost_type
      end

      def primary_item_type
        form = ::PriorAuthority::Steps::ServiceCostForm.build(@application.primary_quote, application: @application)
        form.item_type
      end

      def document(quote)
        return nil unless quote.document

        quote.document.as_json(only: %i[file_name
                                        file_type
                                        file_size
                                        file_path
                                        document_type])
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
