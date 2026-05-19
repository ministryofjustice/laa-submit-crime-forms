require 'rails_helper'

RSpec.describe TestData::ProviderSource do
  describe '.from_environment' do
    before do
      allow(HostEnv).to receive_messages(local?: true, development?: false)
    end

    it 'defaults to the primary dev login provider for the default local data shape' do
      Provider.where(
        auth_provider: described_class::DEV_PROVIDER_ATTRIBUTES.fetch(:auth_provider),
        uid: described_class::DEV_PROVIDER_ATTRIBUTES.fetch(:uid)
      ).delete_all

      source = described_class.from_environment(provider_count: 1, office_code_count: 1, env: {})

      expect(source).not_to be_generated
      expect(source.providers.first).to have_attributes(
        auth_provider: 'entra_id',
        uid: 'test-user',
        email: 'provider@example.com',
        office_codes: %w[1A123B 2A555X]
      )
      expect(source.office_codes).to eq %w[1A123B 2A555X]

      second_source = described_class.from_environment(provider_count: 1, office_code_count: 1, env: {})
      expect(second_source.providers.first).to eq(source.providers.first)
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

    it 'keeps generated providers outside local development environments' do
      allow(HostEnv).to receive_messages(local?: false, development?: false)

      source = described_class.from_environment(provider_count: 1, office_code_count: 1, env: {})

      expect(source).to be_generated
    end
  end
end
