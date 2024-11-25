require 'rails_helper'

RSpec.describe AppStore::V1::Nsm::WorkItem do
  describe '#claim_id' do
    subject { described_class.new({}, claim).claim_id }

    let(:claim) { instance_double(Claim, id: SecureRandom.uuid) }

    it { expect(subject).to eq claim.id }
  end
end
