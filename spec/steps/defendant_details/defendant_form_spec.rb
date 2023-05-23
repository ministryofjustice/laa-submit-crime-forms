require 'rails_helper'

RSpec.describe Steps::DefendantDetailsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      id:,
      full_name:,
      maat:,
      position:,
      main:,
      _destroy:,
    }
  end

  let(:application) { instance_double(Claim, claim_type:, update!: true) }
  let(:id) { SecureRandom.uuid }
  let(:full_name) { 'James' }
  let(:maat) { 'AA1' }
  let(:position) { 0 }
  let(:main) { false }
  let(:claim_type) { ClaimType::NON_STANDARD_MAGISTRATE.to_s }
  let(:_destroy) { nil }

  describe '#maat_required' do
    context 'when claim_type is NOT BREACH_OF_INJUNCTION' do
      it { expect(subject).to be_maat_required}
    end

    context 'when claim_type is BREACH_OF_INJUNCTION' do
      let(:claim_type) { ClaimType::BREACH_OF_INJUNCTION.to_s }

      it { expect(subject).not_to be_maat_required}
    end
  end

  describe 'persisted?' do
    context 'when id is set' do
      it { expect(subject).to be_persisted }
    end

    context 'when id is NOT set' do
      let(:id) { nil }

      it { expect(subject).not_to be_persisted }
    end
  end

  describe '#validations' do
    it { expect(subject).to be_valid }

    context 'when full name is not set' do
      let(:full_name) { nil }

      it 'has the appropriate error messages' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:full_name, :blank)).to be(true)
      end
    end

    context 'when MAAT ID is not set' do
      let(:maat) { nil }

      context 'when claim_type is NOT BREACH_OF_INJUNCTION' do
        it 'has the appropriate error messages' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:maat, :blank)).to be(true)
        end
      end

      context 'when claim_type is BREACH_OF_INJUNCTION' do
        let(:claim_type) { ClaimType::BREACH_OF_INJUNCTION.to_s }

        it { expect(subject).to be_valid}
      end
    end
  end
end
