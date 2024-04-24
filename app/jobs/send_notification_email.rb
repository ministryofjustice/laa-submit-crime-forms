class SendNotificationEmail < ApplicationJob
  def perform(submission)
    Nsm::SubmissionMailer.notify(submission).deliver_now! if submission.is_a?(Claim)
    PriorAuthority::SubmissionMailer.notify(submission).deliver_now! if submission.is_a?(PriorAuthorityApplication)
  end
end
