# frozen_string_literal: true

class FeedbackMailer < GovukNotifyRails::Mailer
  def notify(user_email:, user_rating:, application_env:, user_feedback: '',
             application_name: Rails.configuration.x.application.name)
    set_template('8e51ffcd-0d97-4f27-a1a5-8b7a33eb56b7')
    set_personalisation(
      user_email:,
      user_rating:,
      application_env:,
      user_feedback:,
      application_name:
    )
    mail(to: support_email_address)
  end

  private

  def support_email_address
    Rails.configuration.x.contact.support_email
  end
end
