require 'rails_helper'

RSpec.describe TestData::AppStoreCaseworkerClient do
  describe '#put' do
    subject(:put) { described_class.new.put(message) }

    let(:application_id) { SecureRandom.uuid }
    let(:message) { { application_id: } }
    let(:response) { double(:response, code:, body:) }
    let(:code) { 201 }
    let(:body) { { foo: :bar }.to_json }

    before do
      allow(ENV).to receive(:fetch).and_call_original
      allow(ENV).to receive(:fetch).with('APP_STORE_URL', 'http://localhost:8000').and_return('http://some.url')
      allow(AppStoreTokenProvider.instance).to receive(:authentication_configured?).and_return(false)
      allow(described_class).to receive(:put).and_return(response)
    end

    it 'PUTs the message with the local caseworker test header' do
      expect(described_class).to receive(:put)
        .with(
          "http://some.url/v1/application/#{application_id}",
          body: message.to_json,
          headers: { 'X-Client-Type': 'caseworker' }
        )
        .and_return(response)

      put
    end

    it 'returns the response body' do
      expect(put).to eq('foo' => 'bar')
    end

    context 'when response code is unexpected' do
      let(:code) { 501 }

      it 'raises an error' do
        expect { put }.to raise_error(
          described_class::ResponseError,
          "Unexpected response from AppStore - status 501 for '#{application_id}'"
        )
      end
    end

    context 'when OAuth is configured' do
      before do
        allow(AppStoreTokenProvider.instance).to receive(:authentication_configured?).and_return(true)
      end

      it 'raises an error before submitting test data as a caseworker' do
        expect { put }.to raise_error(
          described_class::AuthenticationError,
          'Caseworker test data submissions require local App Store without OAuth'
        )
      end
    end
  end
end
