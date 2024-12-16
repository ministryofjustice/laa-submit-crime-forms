require 'rails_helper'

RSpec.describe SubmitToAppStore do
  subject { described_class.new }

  let(:submission) { instance_double(Claim, update!: true, state: 'submitted') }
  let(:payload) { { 'application_state' => submission.state } }

  before do
    allow(described_class::PayloadBuilder).to receive(:call)
      .and_return(payload)
    allow(SendNotificationEmail).to receive(:perform_later)
    allow(submission).to receive(:with_lock).and_yield
    allow(submission).to receive(:provider_updated?).and_return(false)
  end

  describe '.perform_later' do
    let(:submission) { create :claim, submit_to_app_store_completed: nil }

    it 'sets a flag' do
      begin
        described_class.perform_later(submission:)
      rescue RedisClient::CannotConnectError
        nil # In the test environment, enqueuing to Redis will fail
      end
      expect(submission.reload.submit_to_app_store_completed).to be false
    end

    it 'sets a timestamp' do
      submission.update(state: :submitted, originally_submitted_at: nil)
      begin
        described_class.perform_later(submission:)
      rescue RedisClient::CannotConnectError
        nil # In the test environment, enqueuing to Redis will fail
      end
      expect(submission.reload.originally_submitted_at).not_to be_nil
    end
  end

  describe '#perform' do
    let(:new_state) { submission.state }
    let(:http_client) { instance_double(AppStoreClient, post: { 'application_state' => new_state }) }

    before do
      allow(AppStoreClient).to receive(:new)
        .and_return(http_client)
    end

    it 'generates a payload' do
      expect(described_class::PayloadBuilder).to receive(:call)
        .with(submission)

      subject.perform(submission:)
    end

    it 'does not queue an email' do
      expect(SendNotificationEmail).not_to receive(:perform_later)
      subject.perform(submission:)
    end

    context 'when email flag is set' do
      before do
        allow(ENV).to receive(:fetch).with('SEND_EMAILS', 'false').and_return 'true'
      end

      it 'queues an email' do
        expect(SendNotificationEmail).to receive(:perform_later).with(submission)
        subject.perform(submission:)
      end
    end

    it 'updates the db record' do
      expect(submission).to receive(:update!).with(submit_to_app_store_completed: true)
      subject.perform(submission:)
    end

    it 'does not update the local record with the app store response by default' do
      expect(AppStoreUpdateProcessor).not_to receive(:call)
      subject.perform(submission:)
    end

    context 'when submission is auto-granted' do
      let(:new_state) { 'auto_grant' }

      it 'updates the local record with the app store response' do
        expect(AppStoreUpdateProcessor).to receive(:call)
        subject.perform(submission:)
      end
    end
  end

  describe '#submit' do
    context 'when submission is PriorAuthorityApplication already in app store' do
      let(:submission) { create(:prior_authority_application, state: :provider_updated) }
      let(:http_client) { instance_double(AppStoreClient, post: true, put: true) }

      before do
        allow(submission).to receive(:provider_updated?).and_return(true)
        allow(AppStoreClient).to receive(:new)
          .and_return(http_client)
      end

      it 'sends a HTTP PUT request' do
        expect(http_client).to receive(:put).with(payload)

        subject.submit(submission)
      end
    end

    context 'when submission is PriorAuthorityApplication not already in app store' do
      let(:submission) { create(:prior_authority_application, state: :submitted) }
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

    context 'when submission is a Claim already in app store' do
      let(:submission) { create(:claim, state: :provider_updated) }
      let(:http_client) { instance_double(AppStoreClient, post: true, put: true) }

      before do
        allow(submission).to receive(:provider_updated?).and_return(true)
        allow(AppStoreClient).to receive(:new)
          .and_return(http_client)
      end

      it 'creates a new AppStoreClient instance' do
        expect(AppStoreClient).to receive(:new)

        subject.submit(submission)
      end

      it 'sends a HTTP message to PUT' do
        expect(http_client).to receive(:put).with(payload)

        subject.submit(submission)
      end
    end

    context 'when submission is a Claim not already in app store' do
      let(:submission) { create(:claim, state: :submitted) }
      let(:http_client) { instance_double(AppStoreClient, post: true, put: true) }

      before do
        allow(AppStoreClient).to receive(:new)
          .and_return(http_client)
      end

      it 'creates a new AppStoreClient instance' do
        expect(AppStoreClient).to receive(:new)

        subject.submit(submission)
      end

      it 'sends a HTTP message to POST' do
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
  end
end
