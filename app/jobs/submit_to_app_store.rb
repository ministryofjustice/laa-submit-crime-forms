class SubmitToAppStore < ApplicationJob
  queue_as :default

  def perform(submission:)
    submit(submission)
    notify(submission)
  end

  def submit(submission)
    payload = PayloadBuilder.call(submission)
    client = AppStoreClient.new

    if submission.is_a?(PriorAuthorityApplication)
      submission.update(status: 'provider_updated') if submission.sent_back?
      submission.app_store_updated_at.present? ? client.put(payload) : client.post(payload)
    else
      client.post(payload)
    end
  end

  def notify(submission)
    SendNotificationEmail.perform_later(submission)
  end
end
