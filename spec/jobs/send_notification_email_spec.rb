require 'rails_helper'

RSpec.describe SendNotificationEmail do
  subject { described_class.new }

  describe '#notify' do
    context 'when submission is a claim' do
      let(:submission) { create(:claim) }
      let(:mailer) { instance_double(ActionMailer::MessageDelivery) }

      it 'triggers an email for nsm' do
        expect(Nsm::SubmissionMailer).to receive(:notify).with(submission).and_return(mailer)
        expect(mailer).to receive(:deliver_now!)

        subject.perform(submission)
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
