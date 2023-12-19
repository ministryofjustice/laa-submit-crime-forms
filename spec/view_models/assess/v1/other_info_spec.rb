require 'rails_helper'

RSpec.describe Assess::V1::OtherInfo do
  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Other relevant information')
    end
  end

  describe '#rows' do
    it 'has correct structure' do
      subject = described_class.new(
        {
          'is_other_info' => 'yes',
          'other_info' => 'Line 1 \nLine 2',
          'concluded' => 'yes',
          'conclusion' => 'Line 1'
        }
      )

      expect(subject.rows).to have_key(:title)
      expect(subject.rows).to have_key(:data)
    end
  end

  describe '#data' do
    context 'other info and case concluded is yes' do
      subject = described_class.new(
        {
          'is_other_info' => 'yes',
          'other_info' => 'Line 1 \nLine 2',
          'concluded' => 'yes',
          'conclusion' => 'Line 1'
        }
      )

      it 'shows correct table data' do
        expect(subject.data).to eq([
                                     { title: 'Any other information', value: 'Yes' },
                                     { title: 'Other information added', value: 'Line 1 \\nLine 2' },
                                     { title: 'Proceedings concluded over 3 months ago', value: 'Yes' },
                                     { title: 'Reason for not claiming within 3 months', value: 'Line 1' }
                                   ])
      end
    end

    context 'other info and case concluded is no' do
      subject = described_class.new(
        {
          'is_other_info' => 'no',
          'other_info' => 'Line 1 \nLine 2',
          'concluded' => 'no',
          'conclusion' => 'Line 1'
        }
      )

      it 'shows correct table data' do
        expect(subject.data).to eq([
                                     { title: 'Any other information', value: 'No' },
                                     { title: 'Proceedings concluded over 3 months ago', value: 'No' },
                                   ])
      end
    end
  end
end
