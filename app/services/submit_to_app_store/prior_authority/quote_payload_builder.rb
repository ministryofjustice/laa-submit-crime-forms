class SubmitToAppStore
  module PriorAuthority
    class QuotePayloadBuilder
      def initialize(application)
        @application = application
      end

      def payload
        @application.quotes.map do |quote|
          form = ::PriorAuthority::Steps::ServiceCostForm.build(quote, application: @application)

          quote.as_json(only: ATTRIBUTES).merge(
            cost_type: form.cost_type,
            item_type: form.item_type,
            document: document(quote)
          )
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

      ATTRIBUTES = %i[
        id
        travel_time
        travel_cost_per_hour
        travel_cost_reason
        contact_full_name
        organisation
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
