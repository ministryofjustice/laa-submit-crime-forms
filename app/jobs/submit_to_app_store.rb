class SubmitToAppStore < ApplicationJob
  queue_as :default

  def self.perform_later(submission:)
    # TODO: Backfill by exporting from app store to generate a migration once this is deployed
    submission.originally_submitted_at = DateTime.current if submission.submitted?
    submission.update!(submit_to_app_store_completed: false)
    super
  end

  def perform(submission:)
    # This job may have been enqueued while the submission was locked, before a DB
    # transaction had been committed. So if we read from the DB straight away we
    # may not receive the latest data. Waiting until we can acquire our own lock
    # means waiting until the previous lock is released, at which point any
    # modifications made as part of that transaction will have been committed
    submission.with_lock do
      submit(submission)
      notify(submission)
      submission.update!(submit_to_app_store_completed: true)
    end
  end

  def submit(submission, include_events: true)
    payload = PayloadBuilder.call(submission, include_events:)
    client = AppStoreClient.new

    submission.provider_updated? ? client.put(payload) : client.post(payload)
  end

  def notify(submission)
    SendNotificationEmail.perform_later(submission) if ENV.fetch('SEND_EMAILS', 'false') == 'true'
  end
end
