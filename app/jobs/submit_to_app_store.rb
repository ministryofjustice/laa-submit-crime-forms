class SubmitToAppStore < ApplicationJob
  queue_as :default

  def perform(submission:)
    submit(submission)
    notify(submission)
  end

  def submit(submission, include_events: true)
    payload = PayloadBuilder.call(submission, include_events:)
    client = AppStoreClient.new

    if submission.is_a?(PriorAuthorityApplication)
      submission.provider_updated? ? client.put(payload) : client.post(payload)
    else
      client.post(payload)
    end
  end

  def notify(submission)
    SendNotificationEmail.perform_later(submission) if ENV.fetch('SEND_EMAILS', 'false') == 'true'
  end
end
