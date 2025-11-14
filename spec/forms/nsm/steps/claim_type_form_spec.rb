require 'rails_helper'

RSpec.describe Nsm::Steps::ClaimTypeForm do
  subject { described_class.new(claim_type:) }

  let(:claim_type) { nil }

  context 'when claim_type is invalid' do
    let(:claim_type) { 'garbage' }

    it 'fails to validate form' do
      subject.validate
      expect(subject.valid?).to be false
    end
  end

  context 'successfully validates form' do
    let(:claim_type) { 'non_standard_magistrate' }

    it 'fails to save form' do
      subject.validate
      expect(subject.valid?).to be true
    end
  end
end
