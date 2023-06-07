require 'rails_helper'

RSpec.describe Steps::AddAnotherForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      add_another:,
    }
  end

  let(:application) { instance_double(Claim) }
  let(:add_another) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(subject.choices).to eq(YesNoAnswer.values)
    end
  end

  describe '#validations' do
    context 'when add_another is blank' do
      it 'to have errors' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:add_another, :inclusion)).to be(true)
      end
    end

    context 'when add_another is yes' do
      let(:add_another) { 'yes' }

      it { expect(subject).to be_valid }
    end

    context 'when add_another is no' do
      let(:add_another) { 'no' }

      it { expect(subject).to be_valid }
    end
  end

  describe '#save' do
    let(:add_another) { 'yes' }

    it 'does not persist anything' do
      expect(subject.save).to be_truthy
    end
  end
end
