require 'rails_helper'

RSpec.describe OfficeCodeService do
  subject { described_class.call(user_login) }

  let(:user_login) { 'LOGIN' }
  let(:known_user_payload) do
    {
      'user' => {
        'userLogin' => user_login
      }
    }.to_json
  end
  let(:populated_code_payload) do
    {
      'officeCodes' => [
        { 'firmOfficeCode' => 'AAAAAA' },
        { 'firmOfficeCode' => 'BBBBBB' }
      ]
    }.to_json
  end
  let(:headers) { { 'Content-type' => 'application/json' } }
  let(:user_offices_endpoint) { 'https://provider-api.example.com/provider-users/LOGIN/provider-offices' }
  let(:populated_codes) { %w[AAAAAA BBBBBB] }
  let(:v1_enabled) { false }

  context 'when all is working correctly' do
    before do
      allow(FeatureFlags).to receive(:provider_api_v1).and_return(double(:provider_api_v1, enabled?: v1_enabled))
      stub_request(:get, user_offices_endpoint).to_return(status: 200, body: populated_code_payload, headers: headers)
    end

    it 'retrieves office codes from the provider data API in 2 steps' do
      expect(subject).to eq populated_codes
    end
  end

  context 'when user has no office codes' do
    before do
      allow(FeatureFlags).to receive(:provider_api_v1).and_return(double(:provider_api_v1, enabled?: v1_enabled))
      stub_request(:get, user_offices_endpoint).to_return(status: 204, headers: headers)
    end

    it 'returns an empty array' do
      expect(subject).to eq []
    end
  end

  context 'when using v1 endpoint' do
    let(:v1_enabled) { true }
    let(:user_offices_endpoint) { 'https://provider-api.example.com/api/v1/provider-users/LOGIN/provider-offices' }
    let(:populated_code_payload) do
      { offices: [
        {
          'officeCodes' => [
            { 'firmOfficeCode' => 'AAAAAA' },
            { 'firmOfficeCode' => 'BBBBBB' }
          ]
        },
        {
          'officeCodes' => [
            { 'firmOfficeCode' => 'CCCCCC' },
            { 'firmOfficeCode' => 'DDDDDD' }
          ]
        }
      ] }.to_json
    end
    let(:populated_codes) { %w[AAAAAA BBBBBB CCCCCC DDDDDD] }

    before do
      allow(FeatureFlags).to receive(:provider_api_v1).and_return(double(:provider_api_v1, enabled?: v1_enabled))
      stub_request(:get, user_offices_endpoint).to_return(status: 200, body: populated_code_payload, headers: headers)
    end

    it 'retrieves office codes from the provider data API in 2 steps' do
      expect(subject).to eq populated_codes
    end
  end

  context 'when endpoint call errors' do
    before do
      allow(FeatureFlags).to receive(:provider_api_v1).and_return(double(:provider_api_v1, enabled?: v1_enabled))
      stub_request(:get, user_offices_endpoint).to_return(status: 500)
    end

    it 'raises an error' do
      expect { subject }.to raise_error(
        'Unexpected status code 500 when querying provider API endpoint provider-users/LOGIN/provider-offices'
      )
    end
  end
end
