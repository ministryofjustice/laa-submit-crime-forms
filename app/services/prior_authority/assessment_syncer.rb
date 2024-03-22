module PriorAuthority
  class AssessmentSyncer
    class << self
      def call(application)
        app_store_record = AppStoreClient.new.get(application.id)

        case application.status
        when 'rejected', 'granted'
          sync_overall_comment(application, app_store_record)
        when 'part_grant'
          sync_overall_comment(application, app_store_record)
          sync_allowances(application, app_store_record)
        when 'sent_back'
          sync_further_info_request(application, app_store_record)
        end
      end

      def sync_overall_comment(application, app_store_record)
        comment_event = app_store_record['events'].select { _1['public'] && _1['event_type'] == 'Event::Decision' }
                                                  .max_by { DateTime.parse(_1['created_at']) }

        application.update(assessment_comment: comment_event.dig('details', 'comment'))
      end

      def sync_allowances(application, app_store_record)
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
          travel_cost_allowed: travel_cost_form.total_cost,
          travel_adjustment_comment: quote_data['travel_adjustment_comment'],
          service_adjustment_comment: quote_data['adjustment_comment']
        )
      end

      def sync_additional_cost(cost, cost_data, application)
        cost_form = build_form(application, cost, Steps::AdditionalCosts::DetailForm, cost_data)
        cost.update(
          total_cost_allowed: cost_form.total_cost,
          adjustment_comment: cost_data['adjustment_comment']
        )
      end

      def sync_further_info_request(application, app_store_record)
        data = app_store_record['application']
        further_info_required = data['updates_needed'].include? 'further_information'
        info_correct_required = data['updates_needed'].include? 'incorrect_information'
        application.update(
          further_information_explanation: further_info_required ? data['further_information_explanation'] : nil,
          incorrect_information_explanation: info_correct_required ? data['incorrect_information_explanation'] : nil
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
