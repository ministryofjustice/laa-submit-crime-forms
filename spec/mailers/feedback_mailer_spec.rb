# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FeedbackMailer, type: :mailer do
  let(:feedback_template) { '8e51ffcd-0d97-4f27-a1a5-8b7a33eb56b7' }
  let(:user_feedback) { 'A feedback comment' }
  let(:user_email) { 'feedback.user@example.com' }
  let(:user_rating) { 1 }
  let(:application_env) { 'test' }

  describe '#notify' do
    subject(:mail) { described_class.notify(**args) }

    let(:args) { { user_email:, user_rating:, user_feedback:, application_env: } }

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the recipient from config' do
      expect(mail.to).to eq([Rails.configuration.x.contact.support_email])
    end

    it 'sets the template' do
      expect(
        mail.govuk_notify_template
      ).to eq feedback_template
    end

    context 'with personalisation' do
      it 'sets personalisation from args' do
        expect(
          mail.govuk_notify_personalisation
        ).to include(user_feedback:, user_email:, user_rating:, application_env:)
      end

      context 'when no comment' do
        let(:args) { { user_email:, user_rating:, application_env: } }

        it 'sets comment to empty' do
          expect(
            mail.govuk_notify_personalisation
          ).to include(user_feedback: '', user_email: user_email, user_rating: user_rating,
                       application_env: application_env)
        end
      end
    end
  end
end
