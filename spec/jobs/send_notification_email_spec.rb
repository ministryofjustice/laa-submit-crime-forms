require 'rails_helper'

RSpec.describe SendNotificationEmail do
  subject { described_class.new }

  describe '.perform_later' do
    let(:submission) { create :claim, send_notification_email_completed: nil }

    it 'sets a flag' do
      described_class.perform_later(submission)
      expect(submission.reload.send_notification_email_completed).to be false
    end
  end

  describe '#notify' do
    context 'when submission is a claim' do
      let(:submission) { create(:claim) }
      let(:mailer) { instance_double(ActionMailer::MessageDelivery, deliver_now!: true) }

      it 'triggers an email for nsm' do
        expect(Nsm::SubmissionMailer).to receive(:notify).with(submission).and_return(mailer)
        expect(mailer).to receive(:deliver_now!)

        subject.perform(submission)
      end

      it 'updates the db record' do
        allow(Nsm::SubmissionMailer).to receive(:notify).and_return(mailer)
        subject.perform(submission)
        expect(submission.reload).to be_send_notification_email_completed
      end
    end

    context 'when submission is a PA application' do
      let(:submission) { create(:prior_authority_application) }
      let(:mailer) { instance_double(ActionMailer::MessageDelivery) }

      it 'triggers an email for prior authority' do
        expect(PriorAuthority::SubmissionMailer).to receive(:notify).with(submission).and_return(mailer)
        expect(mailer).to receive(:deliver_now!)

        subject.perform(submission)
      end
    end
  end
end
