class NotifyAppStore < ApplicationJob
  queue_as :default

  def process(claim:, scorer: RiskAssessment::RiskAssessmentScorer)
    if ENV.key?('REDIS_HOST')
      self.class.perform_later(claim)
    else
      begin
        notify(MessageBuilder.new(claim:, scorer:))
      rescue StandardError => e
        # we only get errors here when processing inline, which we don't want
        # to be visible to the end user, so swallow errors
        Sentry.capture_exception(e)
      end
    end
  end

  def perform(claim, scorer: RiskAssessment::RiskAssessmentScorer)
    notify(MessageBuilder.new(claim:, scorer:))
  end

  def notify(message_builder)
    raise 'SNS notification is not yet enabled' if ENV.key?('SNS_URL')

    # implement and call SNS notification

    # TODO: we only do post requests here as the system is not currently
    # able to support re-sending/submitting an appplication so we can ignore
    # put requests
    post_manager = HttpNotifier.new
    post_manager.post(message_builder.message)
  end
end
