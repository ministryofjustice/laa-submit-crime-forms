module PriorAuthority
  class AssessmentSyncer
    class << self
      def call(application)
        app_store_record = AppStoreClient.new.get(application.id)

        sync_allowances(application, app_store_record)
        sync_overall_comment(application, app_store_record)
        sync_adjustment_comments(application, app_store_record)
      end

      def sync_overall_comment(application, app_store_record)
        comment_event = app_store_record['events'].select { _1['public'] && _1['event_type'] == 'Event::Decision' }
                                                  .max_by { DateTime.parse(_1['created_at']) }

        application.update(assessment_comment: comment_event.dig('details', 'comment'))
      end

      def sync_allowances(application, app_store_record)
        return unless application.status == 'part_grant'

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

      def sync_adjustment_comments(application, app_store_record)
        sync_base_adjustment_comments(application, app_store_record)
        application.additional_costs.each { sync_additional_cost_adjustment_comments(_1, app_store_record) }
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

      def sync_base_adjustment_comments(application, app_store_record)
        quote = application.primary_quote
        travel_adjustment_comment = retrieve_quote_adjustment_comment(quote, app_store_record, adjustment_type: :travel)
        base_adjustment_comment = retrieve_quote_adjustment_comment(quote, app_store_record, adjustment_type: :base)
        quote.update(travel_adjustment_comment:, base_adjustment_comment:)
      end

      def sync_additional_cost_adjustment_comments(additional_cost, app_store_record)
        edit_events = app_store_record['events'].select do |event|
          event['event_type'] == 'Event::Edit' &&
            event['linked_type'] == 'additional_costs' &&
            event['linked_id'] == additional_cost.id
        end
        latest_edit_event = edit_events.max_by { DateTime.parse(_1['created_at']) }
        additional_cost.update(
          adjustment_comment: latest_edit_event&.dig('details', 'comment')
        )
      end

      def retrieve_quote_adjustment_comment(quote, app_store_record, adjustment_type:)
        edit_events = app_store_record['events'].select do |event|
          event['event_type'] == 'Event::Edit' &&
            event['linked_type'] == 'quotes' &&
            event['linked_id'] == quote.id &&
            (adjustment_type == :travel ? travel_adjustment?(event) : !travel_adjustment?(event))
        end
        latest_edit_event = edit_events.max_by { DateTime.parse(_1['created_at']) }
        latest_edit_event&.dig('details', 'comment')
      end

      def travel_adjustment?(event)
        event.dig('details', 'field').in?(%w[travel_time travel_cost_per_hour])
      end
    end
  end
end
