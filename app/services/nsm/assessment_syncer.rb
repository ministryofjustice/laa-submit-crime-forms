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
        sync_overall_comment
        sync_letter_adjustments
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
      if letters['count_original'].present?
        claim.update(allowed_letters: letters['count'],
                     letters: letters['count_original'])
      end
      if letters['uplift_original'].present?
        claim.update(allowed_letters_uplift: letters['uplift'],
                     letters_uplift: letters['uplift_original'])
      end
      claim.update(letters_adjustment_comment: letters['adjustment_comment']) if letters['adjustment_comment'].present?
    end

    def letters
      app_store_record['application']['letters_and_calls'].select { _1['type']['value'] == 'letters' }
                                                          .first
    end
  end
end
