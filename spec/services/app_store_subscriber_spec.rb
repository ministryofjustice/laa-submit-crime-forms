require 'rails_helper'

RSpec.describe AppStoreSubscriber do
  describe '.call' do
    context 'when there is no defined host' do
      it 'does not make a request' do
        expect(AppStoreClient).not_to receive(:new)
        described_class.call
      end
    end

    context 'when there is a host' do
      let(:client) { instance_double(AppStoreClient) }

      around do |example|
        ENV['HOSTS'] = 'example.com'
        example.run
        ENV['HOSTS'] = nil
      end

      before do
        allow(AppStoreClient).to receive(:new).and_return(client)
        allow(client).to receive(:post)
      end

      it 'makes a request' do
        described_class.call
        expect(client).to have_received(:post).with(
          { webhook_url: 'https://example.com/app_store_webhook', subscriber_type: :provider },
          path: 'v1/subscriber'
        )
      end

      context 'when the app store request errors out' do
        before do
          allow(client).to receive(:post).and_raise(StandardError)
          allow(Sentry).to receive(:capture_exception)
        end

        it 'passes the error to Sentry' do
          expect { described_class.call }.not_to raise_error
          expect(Sentry).to have_received(:capture_exception)
        end
      end
    end
  end
end
