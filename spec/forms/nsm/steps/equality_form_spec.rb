require 'rails_helper'

RSpec.describe Nsm::Steps::AnswerEqualityForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      answer_equality:,
    }
  end

  let(:application) { instance_double(Claim, update!: true) }
  let(:answer_equality) { nil }

  describe '#choices' do
    it 'returns the possible choices' do
      expect(subject.choices).to eq(YesNoAnswer.values)
    end
  end

  describe '#validations' do
    context 'when answer_equality is blank' do
      it 'to have errors' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:answer_equality, :inclusion)).to be(true)
      end
    end

    context 'when answer_equality is yes' do
      let(:answer_equality) { 'yes' }

      it { expect(subject).to be_valid }
    end

    context 'when answer_equality is no' do
      let(:answer_equality) { 'no' }

      it { expect(subject).to be_valid }
    end
  end

  describe '#save' do
    let(:answer_equality) { 'yes' }

    it 'is valid' do
      expect(subject).to be_valid
    end

    it 'saves the form' do
      expect(form.save).to be_truthy
    end
  end
end
