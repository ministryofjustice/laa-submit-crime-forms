class SubmitToAppStore < ApplicationJob
  queue_as :default

  def self.perform_later(submission:)
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
      new_data = submit(submission)
      notify(submission)
      update_records(new_data, submission)
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

  def update_records(new_data, submission)
    return if new_data['application_state'] == submission.state

    AppStoreUpdateProcessor.call(new_data, submission)
  end
end
