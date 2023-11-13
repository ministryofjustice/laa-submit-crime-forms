require 'rails_helper'

RSpec.describe CheckAnswers::EqualityAnswersCard do
  subject { described_class.new(claim) }

  describe '#title' do
    let(:claim) { build(:claim) }

    it 'shows correct title' do
      expect(subject.title).to eq('Equality Monitoring')
    end
  end

  describe '#row_data' do
    let(:claim) { build(:claim, :without_equality) }

    context 'no entered information' do
      it 'generates a row with one line of relevant information' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'equality_questions',
              text: 'No, skip the equality questions'
            }
          ]
        )
      end
    end

    context 'entered information' do
      let(:claim) { build(:claim, :with_equality) }

      it 'generates a row with one line of relevant information' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'equality_questions',
              text: 'Yes, answer the equality questions (takes 2 minutes)'
            },
            {
              head_key: 'defendants_ethnicity',
              text: 'White British'
            },
            {
              head_key: 'defendant_identification',
              text: 'Male'
            },
            {
              head_key: 'defendant_disabled',
              text: 'No'
            }
          ]
        )
      end
    end
  end
end
