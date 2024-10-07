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
      claim.with_lock do
        if claim.part_grant? || claim.granted?
          sync_letter_adjustments
          sync_call_adjustments
          sync_work_items
          sync_disbursements
        elsif claim.sent_back? && further_information_exists
          sync_further_info_requests
        end
      end
      # save here to avoid multiple DB updates on claim during the process
      claim.save!
    rescue StandardError => e
      Sentry.capture_message("#{self.class.name} encountered error '#{e}' for claim '#{claim.id}'")
    end

    private

    def sync_overall_comment
      claim.assessment_comment = app_store_record.dig('application', 'assessment_comment').presence
    end

    def further_information_exists
      data['further_information'].present?
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
      work_items.each do |work_item_payload|
        record = claim.work_items.find(work_item_payload['id'])
        sync_work_item(record, work_item_payload)
      end
    end

    def sync_work_item(record, payload)
      record.allowed_time_spent = payload['time_spent'] if payload['time_spent_original'].present?
      record.allowed_uplift = payload['uplift'] if payload['uplift_original'].present?
      record.adjustment_comment = payload['adjustment_comment'] if payload['adjustment_comment'].present?
      record.allowed_work_type = translation_field(payload['work_type']) if payload['work_type_original'].present?
      record.save
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

    def sync_further_info_requests
      data['further_information'].each do |further_info|
        claim.further_informations.find_or_create_by(
          caseworker_id: further_info['caseworker_id'],
          information_requested: further_info['information_requested'],
          requested_at: further_info['requested_at']
        ) do |new_record|
          new_record.resubmission_deadline = resubmission_deadline
        end
      end
    end

    def letters
      data['letters_and_calls'].detect { translation_field(_1['type']) == 'letters' }
    end

    def calls
      data['letters_and_calls'].detect { translation_field(_1['type']) == 'calls' }
    end

    def work_items
      data['work_items']
    end

    def disbursements
      data['disbursements']
    end

    def resubmission_deadline
      data['resubmission_deadline']
    end

    def data
      app_store_record['application']
    end

    def translation_field(field)
      field.is_a?(Hash) ? field['value'] : field
    end
  end
end
