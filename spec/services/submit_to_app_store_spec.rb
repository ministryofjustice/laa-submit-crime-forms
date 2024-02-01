require 'rails_helper'

RSpec.describe SubmitToAppStore do
  subject { described_class.new }

  let(:submission) { instance_double(Claim) }
  let(:payload) { { some: 'message' } }

  before do
    allow(described_class::PayloadBuilder).to receive(:call)
      .and_return(payload)
    allow(ClaimSubmissionMailer).to receive_message_chain(:notify, :deliver_later!)
  end

  describe '#process' do
    context 'when REDIS_HOST is not present' do
      before do
        allow(ENV).to receive(:key?).and_call_original
        allow(ENV).to receive(:key?).with('REDIS_HOST').and_return(false)
        expect(described_class::HttpClient).to receive(:new)
          .and_return(http_client)
      end

      let(:http_client) { instance_double(described_class::HttpClient, post: true) }

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
    let(:http_client) { instance_double(described_class::HttpClient, post: true) }

    before do
      allow(described_class::HttpClient).to receive(:new)
        .and_return(http_client)
    end

    it 'generates a payload' do
      expect(described_class::PayloadBuilder).to receive(:call)
        .with(submission)

      subject.perform(submission)
    end
  end

  describe '#submit' do
    context 'when SNS_URL is not present' do
      let(:http_client) { instance_double(described_class::HttpClient, post: true) }

      before do
        allow(described_class::HttpClient).to receive(:new)
          .and_return(http_client)
      end

      it 'creates a new HttpClient instance' do
        expect(described_class::HttpClient).to receive(:new)

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
      let(:submission) { build(:claim) }
      let(:mailer) { instance_double(ActionMailer::MessageDelivery) }

      it 'triggers an email' do
        expect(ClaimSubmissionMailer).to receive(:notify).with(submission).and_return(mailer)
        expect(mailer).to receive(:deliver_later!)

        subject.notify(submission)
      end
    end

    context 'when submission is a PA application' do
      let(:submission) { build(:prior_authority_application) }
      let(:mailer) { instance_double(ActionMailer::MessageDelivery) }

      it 'triggers no email' do
        expect(ClaimSubmissionMailer).not_to receive(:notify)

        subject.notify(submission)
      end
    end
  end
end
