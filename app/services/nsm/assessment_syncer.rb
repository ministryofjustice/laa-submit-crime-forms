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
    rescue StandardError => e
      Sentry.capture_message("#{self.class.name} encountered error '#{e}' for claim '#{claim.id}'")
    end

    private

    def sync_overall_comment
      comment_event = app_store_record['events'].select { _1['public'] && _1['event_type'] == 'decision' }
                                                .max_by { DateTime.parse(_1['created_at']) }

      if claim.status == 'rejected' || claim.status == 'part_granted'
        claim.update(assessment_comment: comment_event.dig('details', 'comment'))
      end
    end

    def data
      @data ||= app_store_record['application']
    end
  end
end
