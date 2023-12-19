require 'rails_helper'

RSpec.describe Assess::V1::EqualityDetails do
  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Equality monitoring')
    end
  end

  # rubocop:disable RSpec/ExampleLength
  describe '#rows' do
    it 'has correct structure' do
      subject = described_class.new(
        {
          'answer_equality' => {
            'en' => 'Yes, answer the equality questions (takes 2 minutes)',
            'value' => 'yes'
          },
          'ethnic_group' => {
            'en' => 'White British',
            'value' => '01_white_british'
          },
          'gender' => {
            'en' => 'Male',
            'value' => 'm'
          },
          'disability' => {
            'en' => 'No',
            'value' => 'n'
          }
        }
      )

      expect(subject.rows).to have_key(:title)
      expect(subject.rows).to have_key(:data)
    end
  end

  describe '#data' do
    context 'Basic accessibility details' do
      subject = described_class.new(
        {
          'answer_equality' => {
            'en' => 'Yes, answer the equality questions (takes 2 minutes)',
            'value' => 'yes'
          },
          'ethnic_group' => {
            'en' => 'White British',
            'value' => '01_white_british'
          },
          'gender' => {
            'en' => 'Male',
            'value' => 'm'
          },
          'disability' => {
            'en' => 'No',
            'value' => 'n'
          }
        }
      )

      it 'shows correct table data' do
        expect(subject.data).to eq(
          [
            {
              title: 'Equality questions',
              value: TranslationObject.new({ 'value' => 'yes',
'en' => 'Yes, answer the equality questions (takes 2 minutes)' })
            },
            {
              title: 'Defendants ethnic group',
              value: TranslationObject.new({ 'value' => '01_white_british', 'en' => 'White British' })
            },
            {
              title: 'Defendant identification',
              value: TranslationObject.new({ 'value' => 'm', 'en' => 'Male' })
            },
            {
              title: 'Defendant disability',
              value: TranslationObject.new({ 'value' => 'n', 'en' => 'No' })
            }
          ]
        )
      end
    end
  end
  # rubocop:enable RSpec/ExampleLength
end
