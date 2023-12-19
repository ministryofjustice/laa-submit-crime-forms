require 'rails_helper'

RSpec.describe Assess::V1::HearingDetails do
  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Hearing details')
    end
  end

  # rubocop:disable RSpec/ExampleLength
  describe '#rows' do
    it 'has correct structure' do
      subject = described_class.new(
        {
          'first_hearing_date' => '2023-01-02',
          'number_of_hearing' => 3,
          'court' => 'A Mag Court',
          'in_area' => 'yes',
          'youth_court' => 'no',
          'hearing_outcome' => {
            'value' => 'CP01',
            'en' => 'Hearing Done'
          },
          'matter_type' => {
            'value' => 'a_matter',
            'en' => 'A Simple Matter'
          }
        }
      )

      expect(subject.rows).to have_key(:title)
      expect(subject.rows).to have_key(:data)
    end
  end
  # rubocop:enable RSpec/ExampleLength

  describe '#data' do
    subject = described_class.new(
      {
        'first_hearing_date' => '2023-01-02',
        'number_of_hearing' => 3,
        'court' => 'A Mag Court',
        'in_area' => 'yes',
        'youth_court' => 'no',
        'hearing_outcome' => {
          'value' => 'CP01',
          'en' => 'Hearing Done'
        },
        'matter_type' => {
          'value' => '2',
          'en' => 'A Simple Matter'
        }
      }
    )

    it 'shows correct table data' do
      expect(subject.data).to eq(
        [
          { title: 'Date of first hearing', value: '02 January 2023' },
          { title: 'Number of hearings', value: 3 },
          { title: "Magistrates' court", value: 'A Mag Court' },
          { title: 'Court is in designated area of the firm', value: 'Yes' },
          { title: 'Youth court', value: 'No' },
          { title: 'Hearing outcome', value: 'CP01 - Hearing Done' },
          { title: 'Matter type', value: '2 - A Simple Matter' },
        ]
      )
    end
  end
end
