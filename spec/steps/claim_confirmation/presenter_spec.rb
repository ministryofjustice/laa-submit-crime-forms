require 'rails_helper'

RSpec.describe Tasks::ClaimConfirmation, type: :system do
  subject { described_class.new(application:) }

  let(:application) { Claim.new(attributes) }
  let(:attributes) do
    {
      id: id,
      office_code: 'AAA',
      navigation_stack: navigation_stack
    }
  end
  let(:id) { SecureRandom.uuid }
  let(:navigation_stack) { [] }

  describe '#path' do
    it { expect(subject.path).to eq("/applications/#{id}/steps/claim_confirmation") }
  end
end
