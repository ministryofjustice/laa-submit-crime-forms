module Nsm
  class AssessmentSyncer
    def self.call(claim, record:)
      new(claim, record:).call
    end

    attr_reader :claim, :app_store_record

    def initialize(claim, record:)
      @claim = claim
      @app_store_record = record
    end

    def call
      case claim.status
      when 'part_grant'
        Claim.transaction do
          sync_letter_adjustments
          sync_call_adjustments
          sync_overall_comment
          sync_work_items
          sync_disbursements
        end
      when 'provider_requested', 'further_info', 'rejected'
        sync_overall_comment
      end
    rescue StandardError => e
      Sentry.capture_message("#{self.class.name} encountered error '#{e}' for claim '#{claim.id}'")
    end

    private

    def sync_overall_comment
      event_type = claim.provider_requested? || claim.further_info? ? 'send_back' : 'decision'
      comment_event = app_store_record['events'].select { _1['event_type'] == event_type }
                                                .max_by { DateTime.parse(_1['created_at']) }
      claim.update(assessment_comment: comment_event.dig('details', 'comment'))
    end

    def sync_letter_adjustments
      record = letters
      claim.update(allowed_letters: record['count']) if record['count_original'].present?
      claim.update(allowed_letters_uplift: record['uplift']) if record['uplift_original'].present?
      claim.update(letters_adjustment_comment: record['adjustment_comment']) if record['adjustment_comment'].present?
    end

    def sync_call_adjustments
      record = calls
      claim.update(allowed_calls: record['count']) if record['count_original'].present?
      claim.update(allowed_calls_uplift: record['uplift']) if record['uplift_original'].present?
      claim.update(calls_adjustment_comment: record['adjustment_comment']) if record['adjustment_comment'].present?
    end

    def sync_work_items
      work_items.each do |work_item|
        record = claim.work_items.find(work_item['id'])
        record.update(allowed_time_spent: work_item['time_spent']) if work_item['time_spent_original'].present?
        record.update(allowed_uplift: work_item['uplift']) if work_item['uplift_original'].present?
        record.update(adjustment_comment: work_item['adjustment_comment']) if work_item['adjustment_comment'].present?
      end
    end

    def sync_disbursements
      disbursements.each do |disbursement|
        record = claim.disbursements.find(disbursement['id'])
        if disbursement['total_cost_without_vat_original'].present?
          record.update(allowed_total_cost_without_vat: disbursement['total_cost_without_vat'])
        end
        record.update(allowed_vat_amount: disbursement['vat_amount']) if disbursement['vat_amount_original'].present?
        record.update(adjustment_comment: disbursement['adjustment_comment'])
      end
    end

    def letters
      app_store_record['application']['letters_and_calls'].detect { _1['type']['value'] == 'letters' }
    end

    def calls
      app_store_record['application']['letters_and_calls'].detect { _1['type']['value'] == 'calls' }
    end

    def work_items
      app_store_record['application']['work_items']
    end

    def disbursements
      app_store_record['application']['disbursements']
    end
  end
end
