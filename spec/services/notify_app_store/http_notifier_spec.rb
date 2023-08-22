require 'rails_helper'

RSpec.describe NotifyAppStore::HttpNotifier do
  let(:message) { { application_id: SecureRandom.uuid } }
  let(:response) { double(:response, code:) }
  let(:code) { 201 }
  let(:username) { nil }

  before do
    allow(described_class).to receive(:post)
      .and_return(response)
    allow(ENV).to receive(:fetch).and_call_original
    allow(ENV).to receive(:fetch).with('APP_STORE_USERNAME', nil)
                                 .and_return(username)
  end

  context 'when APP_STORE_URL is present' do
    before do
      allow(ENV).to receive(:fetch).with('APP_STORE_URL', 'http://localhost:8000')
                                   .and_return('http://some.url')
    end

    it 'posts the message to the specified URL' do
      expect(described_class).to receive(:post).with('http://some.url/v1/application/', body: message.to_json)

      subject.post(message)
    end
  end

  context 'when APP_STORE_URL is not present' do
    it 'posts the message to default localhost url' do
      expect(described_class).to receive(:post).with('http://localhost:8000/v1/application/', body: message.to_json)

      subject.post(message)
    end
  end

  context 'when APP_STORE_USERNAME is present' do
    let(:username) { 'jimbob' }

    before do
      allow(ENV).to receive(:fetch).with('APP_STORE_PASSWORD')
                                   .and_return('kimbob')
    end

    it 'add basic auth creditals' do
      expect(described_class).to receive(:post).with('http://localhost:8000/v1/application/',
                                                     body: message.to_json,
                                                     basic_auth: { username: 'jimbob', password: 'kimbob' },)

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
