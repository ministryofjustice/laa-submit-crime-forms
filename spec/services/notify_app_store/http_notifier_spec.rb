require 'rails_helper'

RSpec.describe NotifyAppStore::HttpNotifier do
  let(:message) { double(:message) }

  before do
    allow(described_class).to receive(:post)
      .and_return(double(:response, parsed_response: { some: 'message' }))
  end

  context 'when APP_STORE_URL is present' do
    before do
      allow(ENV).to receive(:fetch).with('APP_STORE_URL', 'http://localhost:8000')
                                   .and_return('http://some.url')
    end

    it 'posts the message to the specified URL' do
      expect(described_class).to receive(:post).with('http://some.url/application/', message)

      subject.post(message)
    end
  end

  context 'when APP_STORE_URL is not present' do
    it 'posts the message to default localhost url' do
      expect(described_class).to receive(:post).with('http://localhost:8000/application/', message)

      subject.post(message)
    end
  end
end
