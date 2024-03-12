module PriorAuthority
  class CostSyncer
    class << self
      def call(application)
        return unless application.status == 'part_grant'

        app_store_record = AppStoreClient.new.get(application.id)

        data = app_store_record['application']

        sync_primary_quote(
          application.primary_quote,
          data['quotes'].find { _1['primary'] },
          application
        )

        application.additional_costs.each do |additional_cost|
          sync_additional_cost(
            additional_cost,
            data['additional_costs'].find { _1['id'] == additional_cost.id },
            application
          )
        end
      end

      def sync_primary_quote(quote, quote_data, application)
        base_cost_form = build_form(application, quote, Steps::ServiceCostForm, quote_data)
        travel_cost_form = build_form(application, quote, Steps::TravelDetailForm, quote_data)
        quote.update(
          base_cost_allowed: base_cost_form.total_cost,
          travel_cost_allowed: travel_cost_form.total_cost
        )
      end

      def sync_additional_cost(cost, cost_data, application)
        cost_form = build_form(application, cost, Steps::AdditionalCosts::DetailForm, cost_data)
        cost.update(
          total_cost_allowed: cost_form.total_cost
        )
      end

      def build_form(application, record, form_class, data)
        form_class.new(
          data.slice(*form_class.attribute_names).merge(application:, record:)
        )
      end
    end
  end
end
