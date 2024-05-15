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
      Rails.logger.info "Calling NSM Assessment Syncer"
      case claim.status
      when 'part_grant'
        Rails.logger.info "Part Grant"
        sync_letter_adjustments
        sync_overall_comment
      when 'provider_requested', 'further_info', 'rejected'
        Rails.logger.info "Another State"
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
      Rails.logger.info "Syncing Letter Adjustments"
      update_letters_count(letters)
      update_letters_uplift(letters)
      Rails.logger.info "Syncing Comment"
      claim.update(letters_adjustment_comment: letters['adjustment_comment']) if letters['adjustment_comment'].present?
    end

    def letters
      app_store_record['application']['letters_and_calls'].select { _1['type']['value'] == 'letters' }
                                                          .first
    end

    def update_letters_count(letters)
      Rails.logger.info "Syncing Letter Count"
      return if letters['count_original'].blank?

      claim.update(allowed_letters: letters['count'],
                   letters: letters['count_original'])
    end

    def update_letters_uplift(letters)
      Rails.logger.info "Syncing Letter Uplift"
      return if letters['uplift_original'].blank?

      claim.update(allowed_letters_uplift: letters['uplift'],
                   letters_uplift: letters['uplift_original'])
    end
  end
end
