require 'rails_helper'

RSpec.describe TestData::ProviderSource do
  describe '.from_environment' do
    before do
      allow(HostEnv).to receive_messages(local?: true, development?: false)
    end

    it 'defaults to the primary dev login provider for the default local data shape' do
      source = described_class.from_environment(provider_count: 1, office_code_count: 1, env: {})

      expect(source).not_to be_generated
      expect(source.providers.first).to have_attributes(
        auth_provider: DevLoginProvider::AUTH_PROVIDER,
        uid: DevLoginProvider::UID,
        email: DevLoginProvider::EMAIL,
        office_codes: DevLoginProvider::OFFICE_CODES
      )
      expect(source.office_codes).to eq DevLoginProvider::OFFICE_CODES
    end

    it 'keeps generated providers for explicit high-cardinality data' do
      source = described_class.from_environment(provider_count: 2, office_code_count: 10, env: {})

      expect(source).to be_generated
    end

    it 'keeps generated providers when requested explicitly' do
      source = described_class.from_environment(
        provider_count: 1,
        office_code_count: 1,
        env: { 'PROVIDER_MODE' => 'generated' }
      )

      expect(source).to be_generated
    end

    it 'selects an explicit provider and office-code subset' do
      provider = create(:provider, :other, email: 'chosen@example.com', office_codes: %w[1A123B 2A555X])

      source = described_class.from_environment(
        provider_count: 1,
        office_code_count: 1,
        env: { 'PROVIDER_EMAIL' => provider.email, 'OFFICE_CODES' => '2A555X' }
      )

      expect(source.providers).to eq [provider]
      expect(source.office_codes).to eq ['2A555X']
    end

    it 'rejects office codes that do not belong to the selected provider' do
      provider = create(:provider, :other, email: 'chosen@example.com', office_codes: ['1A123B'])

      expect do
        described_class.from_environment(
          provider_count: 1,
          office_code_count: 1,
          env: { 'PROVIDER_EMAIL' => provider.email, 'OFFICE_CODES' => 'T00001' }
        )
      end.to raise_error(
        ArgumentError,
        'OFFICE_CODES must belong to the selected provider. Unsupported office codes: T00001'
      )
    end
  end
end
