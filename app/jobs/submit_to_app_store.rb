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
      submission.provider_updated? ? client.put(payload) : client.post(payload)
    else
      client.post(payload)
    end
  end

  def notify(submission)
    SendNotificationEmail.perform_later(submission)
  end
end
