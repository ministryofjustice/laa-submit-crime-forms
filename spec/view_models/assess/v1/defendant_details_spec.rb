require 'rails_helper'

RSpec.describe Assess::V1::DefendantDetails do
  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Defendant details')
    end
  end

  # rubocop:disable RSpec/ExampleLength
  describe '#rows' do
    it 'has correct structure' do
      subject = described_class.new(
        {
          'defendants' => [
            {
              'id' => '40fb1f88-6dea-4b03-9087-590436b62dd8',
                'maat' => 'AB12123',
                'main' => true,
                'position' => 1,
                'full_name' => 'Main Defendant'
            },
            {
              'id' => '40fb1f98-6dea-4b03-9087-590436b62dd8',
              'maat' => 'AB454545',
              'main' => false,
              'position' => 2,
              'full_name' => 'Defendant 1'
            },
            {
              'id' => '40fb2f88-6dea-4b03-9087-590436b62dd8',
              'maat' => 'AB676767',
              'main' => false,
              'position' => 3,
              'full_name' => 'Defendant 2'
            }
          ]
        }
      )

      expect(subject.rows).to have_key(:title)
      expect(subject.rows).to have_key(:data)
    end
  end
  # rubocop:enable RSpec/ExampleLength

  describe '#data' do
    context 'Main defendant and additional defendants' do
      subject = described_class.new(
        {
          'defendants' => [
            {
              'id' => '40fb1f88-6dea-4b03-9087-590436b62dd8',
                'maat' => 'AB12123',
                'main' => true,
                'position' => 1,
                'full_name' => 'Main Defendant'
            },
            {
              'id' => '40fb1f98-6dea-4b03-9087-590436b62dd8',
              'maat' => 'AB454545',
              'main' => false,
              'position' => 2,
              'full_name' => 'Defendant 1'
            },
            {
              'id' => '40fb2f88-6dea-4b03-9087-590436b62dd8',
              'maat' => 'AB676767',
              'main' => false,
              'position' => 3,
              'full_name' => 'Defendant 2'
            }
          ]
        }
      )

      it 'shows correct table data' do
        expect(subject.data).to eq([
                                     { title: 'Main defendant full name', value: 'Main Defendant' },
                                     { title: 'Main defendant MAAT ID', value: 'AB12123' },
                                     { title: 'Additional defendant 1 full name', value: 'Defendant 1' },
                                     { title: 'Additional defendant 1 MAAT ID', value: 'AB454545' },
                                     { title: 'Additional defendant 2 full name', value: 'Defendant 2' },
                                     { title: 'Additional defendant 2 MAAT ID', value: 'AB676767' }
                                   ])
      end
    end

    context 'Main defendant and no additional defendants' do
      subject = described_class.new(
        {
          'defendants' => [
            {
              'id' => '40fb1f88-6dea-4b03-9087-590436b62dd8',
                'maat' => 'AB12123',
                'main' => true,
                'position' => 1,
                'full_name' => 'Main Defendant'
            }
          ]
        }
      )

      it 'shows correct table data' do
        expect(subject.data).to eq([
                                     { title: 'Main defendant full name', value: 'Main Defendant' },
                                     { title: 'Main defendant MAAT ID', value: 'AB12123' }
                                   ])
      end
    end
  end
end
