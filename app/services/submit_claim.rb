class SubmitClaim < ApplicationJob
  queue_as :default

  def process(claim:, scorer: RiskAssessment::RiskAssessmentScorer)
    if ENV.key?('REDIS_HOST')
      self.class.perform_later(claim)
    else
      begin
        notify(MessageBuilder.new(claim:, scorer:))
        ClaimSubmissionMailer.notify(claim).deliver_later!
      rescue StandardError => e
        # we only get errors here when processing inline, which we don't want
        # to be visible to the end user, so swallow errors
        Sentry.capture_exception(e)
        true
      end
    end
  end

  def perform(claim, scorer: RiskAssessment::RiskAssessmentScorer)
    notify(MessageBuilder.new(claim:, scorer:))
    ClaimSubmissionMailer.notify(claim).deliver_later!
  end

  def notify(message_builder)
    data = message_builder.message.with_indifferent_access
    claim_id = data['application_id']

    claim = SubmittedClaim.find_or_initialize_by(id: claim_id)
    claim.assign_attributes(convert_params(data))
    claim.received_on ||= Time.zone.today
    claim.save!

    add_events(data, claim)
  end

  def convert_params(data)
    {
      state: data['application_state'],
      risk: data['application_risk'],
      current_version: data['json_schema_version'],
      app_store_updated_at: data['updated_at'],
      application_type: data['application_type'],
      json_schema_version: data['json_schema_version'],
      data: data['application'],
    }
  end

  def add_events(data, claim)
    data['events']&.each do |event|
      claim.events.rehydrate!(event)
    end
    Event::NewVersion.build(claim:)
  end
end
