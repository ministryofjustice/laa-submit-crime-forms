require 'rails_helper'

RSpec.describe Assess::V1::DetailsOfClaim do
  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Claim summary')
    end
  end

  describe '#rows' do
    it 'has correct structure' do
      subject = described_class.new(
        {
          'ufn' => 'ABC/12345',
          'claim_type' => {
            'value' => 'non_standard_magistrate',
            'en' => 'Non-standard fee - magistrate'
          },
          'rep_order_date' => '2023-02-01'
        }
      )

      expect(subject.rows).to have_key(:title)
      expect(subject.rows).to have_key(:data)
    end
  end

  describe '#data' do
    subject = described_class.new(
      {
        'ufn' => 'ABC/12345',
        'claim_type' => {
          'value' => 'non_standard_magistrate',
          'en' => 'Non-standard fee - magistrate'
        },
        'rep_order_date' => '2023-02-01'
      }
    )

    it 'shows correct table data' do
      expect(subject.data).to eq([
                                   { title: 'Unique file number', value: 'ABC/12345' },
                                   { title: 'Type of claim', value: 'Non-standard fee - magistrate' },
                                   { title: 'Representation order date', value: '01 February 2023' },
                                 ])
    end
  end
end
