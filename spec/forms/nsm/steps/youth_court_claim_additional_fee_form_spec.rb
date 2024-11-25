require 'rails_helper'

RSpec.describe Nsm::Steps::YouthCourtClaimAdditionalFeeForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      include_youth_court_fee:,
    }
  end

  let(:application) { instance_double(Claim, update!: true) }
  let(:include_youth_court_fee) { nil }

  describe '#validations' do
    context 'when include_youth_court_fee is blank' do
      it 'to have errors' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:include_youth_court_fee, :inclusion)).to be(true)
      end
    end

    context 'when include_youth_court_fee is yes' do
      let(:include_youth_court_fee) { 'yes' }

      it { expect(subject).to be_valid }
    end

    context 'when include_youth_court_fee is no' do
      let(:include_youth_court_fee) { 'no' }

      it { expect(subject).to be_valid }
    end
  end

  describe '#save' do
    let(:include_youth_court_fee) { 'yes' }

    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'saves the form' do
      expect(form.save).to be_truthy
    end
  end
end
