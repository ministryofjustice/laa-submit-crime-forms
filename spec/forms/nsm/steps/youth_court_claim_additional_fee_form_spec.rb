require 'rails_helper'

RSpec.describe Nsm::Steps::YouthCourtClaimAdditionalFeeForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      youth_court_fee_claimed:,
    }
  end

  let(:application) { instance_double(Claim, update!: true) }
  let(:youth_court_fee_claimed) { nil }

  describe '#validations' do
    context 'when youth_court_fee_claimed is blank' do
      it 'to have errors' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:youth_court_fee_claimed, :inclusion)).to be(true)
      end
    end

    context 'when youth_court_fee_claimed is yes' do
      let(:youth_court_fee_claimed) { 'yes' }

      it { expect(subject).to be_valid }
    end

    context 'when youth_court_fee_claimed is no' do
      let(:youth_court_fee_claimed) { 'no' }

      it { expect(subject).to be_valid }
    end
  end

  describe '#save' do
    let(:youth_court_fee_claimed) { 'yes' }

    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'saves the form' do
      expect(form.save).to be_truthy
    end
  end
end
