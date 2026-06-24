require 'rails_helper'
require 'request_store'

RSpec.describe ProviderDataApiClient do
  let(:request_id) { 'rails-request-id' }

  before { OutboundRequestId.set(request_id) }

  after { RequestStore.clear! }

  describe '.user_office_details' do
    let(:endpoint) { 'https://provider-api.example.com/api/v1/provider-users/LOGIN/provider-offices' }

    it 'sends a request-id header' do
      api_request = stub_request(:get, endpoint)
                    .with(headers: { 'request-id' => request_id })
                    .to_return(status: 204)

      described_class.user_office_details('LOGIN')

      expect(api_request).to have_been_requested
    end
  end

  describe '.contract_active?' do
    let(:endpoint) do
      'https://provider-api.example.com/provider-offices/1A123B/schedules?areaOfLaw=CRIME%20LOWER'
    end

    before { allow(HostEnv).to receive(:uat?).and_return(false) }

    it 'sends a request-id header' do
      api_request = stub_request(:head, endpoint)
                    .with(headers: { 'request-id' => request_id })
                    .to_return(status: 200)

      described_class.contract_active?('1A123B')

      expect(api_request).to have_been_requested
    end
  end
end
