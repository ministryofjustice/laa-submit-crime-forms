require 'rails_helper'

RSpec.describe Tasks::ClaimConfirmation, type: :system do
  subject { described_class.new(application:) }

  let(:application) { build(:claim, attributes) }
  let(:attributes) do
    {
      id:,
      navigation_stack:
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:navigation_stack) { [] }

  describe '#path' do
    it { expect(subject.path).to eq("/applications/#{id}/steps/claim_confirmation") }
  end
end
