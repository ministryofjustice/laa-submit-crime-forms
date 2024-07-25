module PriorAuthority
  class AssessmentSyncer
    def self.call(application, record:)
      new(application, record:).call
    end

    attr_reader :application, :app_store_record

    def initialize(application, record:)
      @application = application
      @app_store_record = record
    end

    def call
      application.with_lock do
        case application.status
        when 'rejected', 'granted'
          sync_overall_comment
        when 'part_grant'
          sync_overall_comment
          sync_allowances
        when 'sent_back'
          sync_sent_back_request
        end
      end
    rescue StandardError => e
      Sentry.capture_message("#{self.class.name} encountered error '#{e}' for application '#{application.id}'")
    end

    private

    def sync_overall_comment
      comment_event = app_store_record['events'].select { _1['public'] && _1['event_type'] == 'decision' }
                                                .max_by { DateTime.parse(_1['created_at']) }

      application.update(assessment_comment: comment_event.dig('details', 'comment'))
    end

    def sync_allowances
      sync_primary_quote(application.primary_quote, data['quotes'].find { _1['primary'] })

      application.additional_costs.each do |additional_cost|
        sync_additional_cost(
          additional_cost,
          data['additional_costs'].find { _1['id'] == additional_cost.id },
        )
      end
    end

    def sync_primary_quote(quote, quote_data)
      base_cost_form = build_form(application, quote, Steps::ServiceCostForm, quote_data)
      travel_cost_form = build_form(application, quote, Steps::TravelDetailForm, quote_data)

      quote.update(
        base_cost_allowed: base_cost_form.total_cost,
        travel_cost_allowed: travel_cost_form.total_cost,
        travel_adjustment_comment: quote_data['travel_adjustment_comment'],
        service_adjustment_comment: quote_data['adjustment_comment']
      )
    end

    def sync_additional_cost(cost, cost_data)
      cost_form = build_form(application, cost, Steps::AdditionalCosts::DetailForm, cost_data)

      cost.update(
        total_cost_allowed: cost_form.total_cost,
        adjustment_comment: cost_data['adjustment_comment']
      )
    end

    def sync_sent_back_request
      application.update(
        incorrect_information_explanation: incorrect_information_explanation,
        resubmission_deadline: resubmission_deadline,
        resubmission_requested: DateTime.current
      )

      sync_further_info_request if further_info_required?
      sync_incorrect_info_request if info_correction_required?
    end

    def further_info_required?
      data['updates_needed'].include?('further_information')
    end

    def incorrect_information_explanation
      data['incorrect_information_explanation'] if info_correction_required?
    end

    def info_correction_required?
      data['updates_needed'].include?('incorrect_information')
    end

    def resubmission_deadline
      data['resubmission_deadline']
    end

    def sync_further_info_request
      data['further_information'].each do |further_info|
        application.further_informations.find_or_create_by(
          caseworker_id: further_info['caseworker_id'],
          information_requested: further_info['information_requested'],
          requested_at: further_info['requested_at']
        )
      end
    end

    def sync_incorrect_info_request
      latest_incorrect_info = data['incorrect_information'].max_by { _1['requested_at'] }

      application.incorrect_informations.create(
        {
          caseworker_id: latest_incorrect_info['caseworker_id'],
          information_requested: latest_incorrect_info['information_requested'],
          requested_at: latest_incorrect_info['requested_at']
        }
      )
    end

    def data
      @data ||= app_store_record['application']
    end

    def build_form(application, record, form_class, data)
      form_class.new(
        data.slice(*form_class.attribute_names).merge(application:, record:)
      )
    end
  end
end
