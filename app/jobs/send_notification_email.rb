class SendNotificationEmail < ApplicationJob
  def self.perform_later(submission)
    submission.update!(send_notification_email_completed: false)
    super
  end

  def perform(submission)
    Nsm::SubmissionMailer.notify(submission).deliver_now! if submission.is_a?(Claim)
    PriorAuthority::SubmissionMailer.notify(submission).deliver_now! if submission.is_a?(PriorAuthorityApplication)
    submission.update!(send_notification_email_completed: true)
  end
end
