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
      sync_overall_comment
      if claim.part_grant?
        Claim.transaction do
          sync_letter_adjustments
          sync_call_adjustments
          sync_work_items
          sync_disbursements
        end
      end
      # save here to avoid multiple DB updates on claim during the process
      claim.save!
    rescue StandardError => e
      Sentry.capture_message("#{self.class.name} encountered error '#{e}' for claim '#{claim.id}'")
    end

    private

    def sync_overall_comment
      event_type = claim.provider_requested? || claim.further_info? ? 'send_back' : 'decision'
      comment_event = app_store_record['events'].select { _1['event_type'] == event_type }
                                                .max_by { DateTime.parse(_1['created_at']) }
      claim.assessment_comment = comment_event.dig('details', 'comment')
    end

    def sync_letter_adjustments
      record = letters
      claim.allowed_letters = record['count'] if record['count_original'].present?
      claim.allowed_letters_uplift = record['uplift'] if record['uplift_original'].present?
      claim.letters_adjustment_comment = record['adjustment_comment'] if record['adjustment_comment'].present?
    end

    def sync_call_adjustments
      record = calls
      claim.allowed_calls = record['count'] if record['count_original'].present?
      claim.allowed_calls_uplift = record['uplift'] if record['uplift_original'].present?
      claim.calls_adjustment_comment = record['adjustment_comment'] if record['adjustment_comment'].present?
    end

    def sync_work_items
      work_items.each do |work_item|
        record = claim.work_items.find(work_item['id'])
        record.allowed_time_spent = work_item['time_spent'] if work_item['time_spent_original'].present?
        record.allowed_uplift = work_item['uplift'] if work_item['uplift_original'].present?
        record.adjustment_comment = work_item['adjustment_comment'] if work_item['adjustment_comment'].present?
        record.save
      end
    end

    def sync_disbursements
      fields = %w[total_cost_without_vat miles apply_vat vat_amount]
      disbursements.each do |disbursement|
        record = claim.disbursements.find(disbursement['id'])
        fields.each do |field|
          record["allowed_#{field}"] = disbursement[field] if disbursement["#{field}_original"]
        end
        record.adjustment_comment = disbursement['adjustment_comment']
        record.save
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
