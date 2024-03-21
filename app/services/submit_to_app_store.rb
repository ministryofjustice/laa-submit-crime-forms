class SubmitToAppStore < ApplicationJob
  queue_as :default

  def process(submission:)
    if ENV.key?('REDIS_HOST')
      self.class.perform_later(submission)
    else
      begin
        submit(submission)
        notify(submission)
      rescue StandardError => e
        # we only get errors here when processing inline, which we don't want
        # to be visible to the end user, so swallow errors
        Sentry.capture_exception(e)
      end
    end
  end

  def perform(submission)
    submit(submission)
    notify(submission)
  end

  def submit(submission)
    payload = PayloadBuilder.call(submission)
    raise 'SNS notification is not yet enabled' if ENV.key?('SNS_URL')

    # implement and call SNS notification

    # TODO: we only do post requests here as the system is not currently
    # able to support re-sending/submitting an appplication so we can ignore
    # put requests
    post_manager = AppStoreClient.new
    post_manager.post(payload)
  end

  def notify(submission)
    Nsm::SubmissionMailer.notify(submission).deliver_now! if submission.is_a?(Claim)
    ::PriorAuthority::SubmissionMailer.notify(submission).deliver_now! if submission.is_a?(PriorAuthorityApplication)
  end
end
