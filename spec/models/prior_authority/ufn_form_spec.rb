require 'rails_helper'

RSpec.describe PriorAuthority::UfnForm do
  describe '#extended_update' do
    it 'will not regenerate an existing laa reference if the record is already a draft' do
      provider = create(:provider)
      record = described_class.create provider: provider, status: 'draft', laa_reference: 'AAA123'

      record.extended_update(ufn: '123456')

      expect(record.reload.ufn).to eq '123456'
      expect(record.laa_reference).to eq 'AAA123'
    end

    it 'ensures a unique LAA reference' do
      provider = create(:provider)
      PriorAuthorityApplication.create! provider: provider, laa_reference: 'LAA-123456'
      record = PriorAuthorityApplication.create(provider: provider, status: 'pre_draft').becomes(described_class)

      allow(SecureRandom).to receive(:base58).with(6).and_return('123456', '987654')

      record.extended_update(ufn: '123456')

      expect(record.reload.ufn).to eq '123456'
      expect(record.laa_reference).to eq 'LAA-987654'
    end
  end
end
