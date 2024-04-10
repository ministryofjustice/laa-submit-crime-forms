require 'rails_helper'

RSpec.describe SubmitToAppStore do
  subject { described_class.new }

  let(:submission) { instance_double(Claim) }
  let(:payload) { { some: 'message' } }

  before do
    allow(described_class::PayloadBuilder).to receive(:call)
      .and_return(payload)
    allow(Nsm::SubmissionMailer).to receive_message_chain(:notify, :deliver_now!)
    allow(PriorAuthority::SubmissionMailer).to receive_message_chain(:notify, :deliver_now!)
  end

  describe '#process' do
    context 'when REDIS_HOST is not present' do
      before do
        allow(ENV).to receive(:key?).and_call_original
        allow(ENV).to receive(:key?).with('REDIS_HOST').and_return(false)
        expect(AppStoreClient).to receive(:new)
          .and_return(http_client)
      end

      let(:http_client) { instance_double(AppStoreClient, post: true) }

      it 'does not raise any errors' do
        expect { subject.process(submission:) }.not_to raise_error
      end

      it 'sends a HTTP message' do
        expect(http_client).to receive(:post).with(payload)

        subject.process(submission:)
      end

      describe 'when error during notify process' do
        before do
          allow(http_client).to receive(:post).and_raise('annoying_error')
        end

        it 'sends the error to sentry and ignores it' do
          expect(Sentry).to receive(:capture_exception)

          expect { subject.process(submission:) }.not_to raise_error
        end
      end
    end

    context 'when REDIS_HOST is present' do
      before do
        allow(ENV).to receive(:key?).with('REDIS_HOST').and_return(true)
      end

      it 'schedules the job' do
        expect(described_class).to receive(:perform_later).with(submission)

        subject.process(submission:)
      end
    end
  end

  describe '#perform' do
    let(:http_client) { instance_double(AppStoreClient, post: true) }

    before do
      allow(AppStoreClient).to receive(:new)
        .and_return(http_client)
    end

    it 'generates a payload' do
      expect(described_class::PayloadBuilder).to receive(:call)
        .with(submission)

      subject.perform(submission)
    end
  end

  describe '#submit' do
    context 'when submission is PriorAuthorityApplication already in app store' do
      let(:submission) { create(:prior_authority_application, app_store_updated_at: DateTime.now)}
      let(:http_client) { instance_double(AppStoreClient, post: true, put: true) }

      before do
        allow(AppStoreClient).to receive(:new)
          .and_return(http_client)
      end

      it 'sends a HTTP PUT request' do
        expect(http_client).to receive(:put).with(payload)

        subject.submit(submission)
      end
    end

    context 'when submission is PriorAuthorityApplication not already in app store' do
      let(:submission) { create(:prior_authority_application, app_store_updated_at: nil)}
      let(:http_client) { instance_double(AppStoreClient, post: true, put: true) }

      before do
        allow(AppStoreClient).to receive(:new)
          .and_return(http_client)
      end

      it 'sends a HTTP POST request' do
        expect(http_client).to receive(:post).with(payload)

        subject.submit(submission)
      end
    end

    context 'when submission provider has updated PriorAuthorityApplication' do
      let(:submission) { create(:prior_authority_application, app_store_updated_at: nil, status: 'sent_back')}
      let(:http_client) { instance_double(AppStoreClient, post: true, put: true) }

      before do
        allow(AppStoreClient).to receive(:new)
          .and_return(http_client)
      end

      it 'updates application status to provider_updated' do
        subject.submit(submission)

        expect(submission.status).to eq('provider_updated')
      end
    end

    context 'when SNS_URL is not present' do
      let(:http_client) { instance_double(AppStoreClient, post: true) }

      before do
        allow(AppStoreClient).to receive(:new)
          .and_return(http_client)
      end

      it 'creates a new AppStoreClient instance' do
        expect(AppStoreClient).to receive(:new)

        subject.submit(submission)
      end

      it 'sends a HTTP message' do
        expect(http_client).to receive(:post).with(payload)

        subject.submit(submission)
      end

      describe 'when error during notify process' do
        before do
          allow(http_client).to receive(:post).and_raise('annoying_error')
        end

        it 'allows the error to be raised - should reset the sidekiq job' do
          expect { subject.submit(submission) }.to raise_error('annoying_error')
        end
      end
    end

    context 'when SNS_URL is present' do
      before do
        allow(ENV).to receive(:key?).with('SNS_URL').and_return(true)
      end

      it 'raises an error' do
        expect { subject.submit(submission) }.to raise_error('SNS notification is not yet enabled')
      end
    end
  end

  describe '#notify' do
    context 'when submission is a claim' do
      let(:submission) { create(:claim) }
      let(:mailer) { instance_double(ActionMailer::MessageDelivery) }

      it 'triggers an email for nsm' do
        expect(Nsm::SubmissionMailer).to receive(:notify).with(submission).and_return(mailer)
        expect(mailer).to receive(:deliver_now!)

        subject.notify(submission)
      end
    end

    context 'when submission is a PA application' do
      let(:submission) { create(:prior_authority_application) }
      let(:mailer) { instance_double(ActionMailer::MessageDelivery) }

      it 'triggers an email for prior authority' do
        expect(PriorAuthority::SubmissionMailer).to receive(:notify).with(submission).and_return(mailer)
        expect(mailer).to receive(:deliver_now!)

        subject.notify(submission)
      end
    end
  end
end
