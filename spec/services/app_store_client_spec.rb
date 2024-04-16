require 'rails_helper'

RSpec.describe AppStoreClient, :stub_oauth_token do
  describe '#get_all' do
    let(:response) { double(:response, code:, body:) }
    let(:code) { 200 }
    let(:body) { { some: :data }.to_json }
    let(:username) { nil }
    let(:claim) { instance_double(Claim, id: SecureRandom.uuid) }

    before do
      allow(described_class).to receive(:get)
        .and_return(response)
      allow(ENV).to receive(:fetch).and_call_original
    end

    context 'when APP_STORE_URL is present' do
      before do
        allow(ENV).to receive(:fetch).with('APP_STORE_URL', 'http://localhost:8000')
                                     .and_return('http://some.url')
      end

      it 'get the claims to the specified URL' do
        expect(described_class).to receive(:get)
          .with('http://some.url/v1/applications?since=1&count=2',
                headers: { authorization: 'Bearer test-bearer-token' })

        subject.get_all(since: 1, count: 2)
      end

      context 'when authentication is not configured' do
        before do
          allow(ENV).to receive(:fetch).with('APP_STORE_TENANT_ID', nil).and_return(nil)
        end

        it 'gets the claims without headers' do
          expect(described_class).to receive(:get)
            .with('http://some.url/v1/applications?since=1&count=2', { headers: { 'X-Client-Type': 'provider' } })

          subject.get_all(since: 1, count: 2)
        end
      end
    end

    context 'when APP_STORE_URL is not present' do
      it 'get the claims to default localhost url' do
        expect(described_class).to receive(:get)
          .with('http://localhost:8000/v1/applications?since=1&count=2',
                headers: { authorization: 'Bearer test-bearer-token' })

        subject.get_all(since: 1, count: 2)
      end
    end

    context 'when response code is 200 - ok' do
      it 'returns the parsed json' do
        expect(subject.get_all(since: 1, count: 2)).to eq('some' => 'data')
      end
    end

    context 'when response code is unexpected (neither 201 or 209)' do
      let(:code) { 501 }

      it 'raises and error' do
        expect { subject.get_all(since: 1, count: 2) }.to raise_error(
          "Unexpected response from AppStore - status 501 for '/v1/applications?since=1&count=2'"
        )
      end
    end
  end

  describe '#put' do
    let(:application_id) { SecureRandom.uuid }
    let(:message) { { application_id: } }
    let(:response) { double(:response, code:) }
    let(:code) { 201 }
    let(:username) { nil }

    before do
      allow(described_class).to receive(:put)
        .and_return(response)
      allow(ENV).to receive(:fetch).and_call_original
    end

    context 'when APP_STORE_URL is present' do
      before do
        allow(ENV).to receive(:fetch).with('APP_STORE_URL', 'http://localhost:8000')
                                     .and_return('http://some.url')
      end

      it 'posts the message to the specified URL' do
        expect(described_class).to receive(:put)
          .with("http://some.url/v1/application/#{application_id}",
                body: message.to_json,
                headers: { authorization: 'Bearer test-bearer-token' })

        subject.put(message)
      end

      context 'when authentication is not configured' do
        before do
          allow(ENV).to receive(:fetch).with('APP_STORE_TENANT_ID', nil).and_return(nil)
        end

        it 'posts the message without headers' do
          expect(described_class).to receive(:put)
            .with("http://some.url/v1/application/#{application_id}",
                  body: message.to_json,
                  headers: { 'X-Client-Type': 'provider' })

          subject.put(message)
        end
      end
    end

    context 'when APP_STORE_URL is not present' do
      it 'posts the message to default localhost url' do
        expect(described_class).to receive(:put)
          .with("http://localhost:8000/v1/application/#{application_id}",
                body: message.to_json,
                headers: { authorization: 'Bearer test-bearer-token' })

        subject.put(message)
      end
    end

    context 'when response code is 201 - created' do
      it 'returns a created status' do
        expect(subject.put(message)).to eq(:success)
      end
    end

    context 'when response code is unexpected' do
      let(:code) { 501 }

      it 'raises and error' do
        expect { subject.put(message) }.to raise_error(
          "Unexpected response from AppStore - status 501 for '#{message[:application_id]}'"
        )
      end
    end
  end

  describe '#post' do
    let(:message) { { application_id: SecureRandom.uuid } }
    let(:response) { double(:response, code:) }
    let(:code) { 201 }
    let(:username) { nil }

    before do
      allow(described_class).to receive(:post)
        .and_return(response)
      allow(ENV).to receive(:fetch).and_call_original
    end

    context 'when APP_STORE_URL is present' do
      before do
        allow(ENV).to receive(:fetch).with('APP_STORE_URL', 'http://localhost:8000')
                                     .and_return('http://some.url')
      end

      it 'posts the message to the specified URL' do
        expect(described_class).to receive(:post)
          .with('http://some.url/v1/application/',
                body: message.to_json,
                headers: { authorization: 'Bearer test-bearer-token' })

        subject.post(message)
      end

      context 'when authentication is not configured' do
        before do
          allow(ENV).to receive(:fetch).with('APP_STORE_TENANT_ID', nil).and_return(nil)
        end

        it 'posts the message without headers' do
          expect(described_class).to receive(:post)
            .with('http://some.url/v1/application/',
                  body: message.to_json,
                  headers: { 'X-Client-Type': 'provider' })

          subject.post(message)
        end
      end
    end

    context 'when APP_STORE_URL is not present' do
      it 'posts the message to default localhost url' do
        expect(described_class).to receive(:post)
          .with('http://localhost:8000/v1/application/',
                body: message.to_json,
                headers: { authorization: 'Bearer test-bearer-token' })

        subject.post(message)
      end
    end

    context 'when response code is 201 - created' do
      it 'returns a created status' do
        expect(subject.post(message)).to eq(:success)
      end
    end

    context 'when response code is 409 - conflict' do
      let(:code) { 409 }

      it 'returns a warning status' do
        expect(subject.post(message)).to eq(:warning)
      end

      it 'sends a Sentry message' do
        expect(Sentry).to receive(:capture_message).with(
          "Application ID already exists in AppStore for '#{message[:application_id]}'"
        )

        subject.post(message)
      end
    end

    context 'when response code is unexpected (neither 201 or 209)' do
      let(:code) { 501 }

      it 'raises and error' do
        expect { subject.post(message) }.to raise_error(
          "Unexpected response from AppStore - status 501 for '#{message[:application_id]}'"
        )
      end
    end
  end
end
