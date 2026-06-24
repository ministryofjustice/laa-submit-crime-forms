require 'rails_helper'
require 'request_store'

RSpec.describe OutboundRequestId do
  after { RequestStore.clear! }

  describe '.current' do
    it 'returns the request id stored for the current request' do
      described_class.set('rails-request-id')

      expect(described_class.current).to eq('rails-request-id')
    end

    it 'generates a unique NSCC Submit id when no request id is stored' do
      allow(SecureRandom).to receive(:uuid).and_return('first-uuid', 'second-uuid')

      expect(described_class.current).to eq('nscc-submit-first-uuid')
      expect(described_class.current).to eq('nscc-submit-second-uuid')
    end
  end

  describe '.headers' do
    it 'returns a request-id header' do
      described_class.set('rails-request-id')

      expect(described_class.headers).to eq('request-id' => 'rails-request-id')
    end
  end
end
