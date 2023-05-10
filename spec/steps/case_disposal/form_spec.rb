require 'rails_helper'

RSpec.describe Steps::CaseDisposalForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      plea:,
    }
  end

  let(:application) do
    instance_double(Claim, update!: true)
  end

  let(:plea) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(
        subject.choices
      ).to eq([Plea::GUILTY, Plea::NOT_GUILTY])
    end
  end

  describe '#save' do
    context 'when `plea` is not provided' do
      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:plea, :inclusion)).to be(true)
      end
    end

    context 'when `plea` is not valid' do
      let(:plea) { 'maybe' }

      it 'returns false' do
        expect(subject.save).to be(false)
      end

      it 'has a validation error on the field' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:plea, :inclusion)).to be(true)
      end
    end

    context 'when `plea` is valid' do
      context 'when answer is `guilty`' do
        let(:plea) { 'guilty' }

        it 'updates the record' do
          subject.save
          expect(application).to have_received(:update!).with('plea' => Plea::GUILTY)
        end
      end

      context 'when answer is `not_guilty`' do
        let(:plea) { 'not_guilty' }

        it 'updates the record' do
          subject.save
          expect(application).to have_received(:update!).with('plea' => Plea::NOT_GUILTY)
        end
      end
    end
  end
end
