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

    context 'when stubbing HTTParty' do
      before do
        allow(described_class).to receive(:post).and_return(response)
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

        it 'raises an error' do
          expect { subject.post(message) }.to raise_error(
            "Application ID already exists in AppStore for '#{message[:application_id]}'"
          )
        end
      end

      context 'when response code is unexpected (neither 201 or 209)' do
        let(:code) { 501 }

        it 'raises an error' do
          expect { subject.post(message) }.to raise_error(
            "Unexpected response from AppStore - status 501 for '#{message[:application_id]}'"
          )
        end
      end
    end

    context 'when not stubbing HTTParty' do
      context 'when authentication is not configured' do
        before do
          allow(ENV).to receive(:fetch).and_call_original
          allow(ENV).to receive(:fetch).with('APP_STORE_TENANT_ID', nil).and_return(nil)
          allow(ENV).to receive(:fetch).with('APP_STORE_URL', 'http://localhost:8000').and_return('http://some.url')
        end

        it 'posts the message without headers' do
          http_stub = stub_request(:post, 'http://some.url/v1/application/').with(
            body: message.to_json,
            headers: {
              'Content-Type' => 'application/json',
              'X-Client-Type' => 'provider'
            }
          ).to_return(status: 200, body: '', headers: {})
          subject.post(message)

          expect(http_stub).to have_been_requested
        end
      end
    end
  end

  describe '#get' do
    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('APP_STORE_TENANT_ID', nil).and_return(nil)
    end

    let(:id) { 'some-id' }
    let(:response) { { 'foo' => 'bar' } }

    it 'gets the the requested item' do
      http_stub = stub_request(:get, "http://localhost:8000/v1/application/#{id}").with(
        headers: {
          'Content-Type' => 'application/json',
          'X-Client-Type' => 'provider'
        }
      ).to_return(status: 200, body: response.to_json, headers: {})
      expect(subject.get(id)).to eq response

      expect(http_stub).to have_been_requested
    end
  end

  describe '#delete' do
    let(:message) { { foo: :bar } }
    let(:path) { 'v1/something' }

    let(:stub) do
      stub_request(:delete, "http://some.url/#{path}").with(
        body: message.to_json,
      ).to_return(status:)
    end

    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('APP_STORE_TENANT_ID', nil).and_return(nil)
      allow(ENV).to receive(:fetch).with('APP_STORE_URL', 'http://localhost:8000').and_return('http://some.url')

      stub
    end

    context 'when HTTP request succeeds' do
      let(:status) { 204 }

      it 'posts the message without headers' do
        expect(subject.delete(message, path:)).to eq :success

        expect(stub).to have_been_requested
      end
    end

    context 'when HTTP request fails' do
      let(:status) { 500 }

      it 'raises an error' do
        expect { subject.delete(message, path:) }.to raise_error(
          'Unexpected response from AppStore - status 500 from delete v1/something'
        )
      end
    end
  end
end
