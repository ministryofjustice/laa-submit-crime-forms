require 'rails_helper'

RSpec.describe Assess::V1::ClaimDetails do
  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Claim details')
    end
  end

  describe '#rows' do
    it 'has correct structure' do
      subject = described_class.new(
        {
          'prosecution_evidence' => 5,
          'defence_statement' => 10,
          'number_of_witnesses' => 2,
          'supplemental_claim' => 'no',
          'preparation_time' => 'yes',
          'time_spent' => 110,
          'work_before' => 'yes',
          'work_before_date' => '2023-01-20',
          'work_after' => 'yes',
          'work_after_date' => '2023-02-02'
        }
      )

      expect(subject.rows).to have_key(:title)
      expect(subject.rows).to have_key(:data)
    end
  end

  describe '#data' do
    context 'work done before and after' do
      subject = described_class.new(
        {
          'prosecution_evidence' => 5,
          'defence_statement' => 10,
          'number_of_witnesses' => 2,
          'supplemental_claim' => 'no',
          'preparation_time' => 'yes',
          'time_spent' => 110,
          'work_before' => 'yes',
          'work_before_date' => '2023-01-20',
          'work_after' => 'yes',
          'work_after_date' => '2023-02-02'
        }
      )

      it 'shows correct table data' do
        expect(subject.data).to eq([
                                     { title: 'Number of pages of prosecution evidence', value: 5 },
                                     { title: 'Number of pages of defence statements', value: 10 },
                                     { title: 'Number of witnesses', value: 2 },
                                     { title: 'Supplemental claim', value: 'No' },
                                     { title: 'Recorded evidence', value: 'Yes' },
                                     { title: 'Recorded evidence', value: '1 Hour 50 Mins' },
                                     { title: 'Work done before order was granted', value: 'Yes' },
                                     { title: 'Date of work before order was granted', value: '20 January 2023' },
                                     { title: 'Work was done after last hearing', value: 'Yes' },
                                     { title: 'Date of work after last hearing', value: '02 February 2023' }
                                   ])
      end
    end

    context 'No work done or evidence recorded' do
      subject = described_class.new(
        {
          'prosecution_evidence' => 5,
          'defence_statement' => 10,
          'number_of_witnesses' => 2,
          'supplemental_claim' => 'no',
          'preparation_time' => 'no',
          'time_spent' => 110,
          'work_before' => 'no',
          'work_after' => 'no'
        }
      )

      it 'shows correct table data' do
        expect(subject.data).to eq([
                                     { title: 'Number of pages of prosecution evidence', value: 5 },
                                     { title: 'Number of pages of defence statements', value: 10 },
                                     { title: 'Number of witnesses', value: 2 },
                                     { title: 'Supplemental claim', value: 'No' },
                                     { title: 'Recorded evidence', value: 'No' },
                                     { title: 'Work done before order was granted', value: 'No' },
                                     { title: 'Work was done after last hearing', value: 'No' }
                                   ])
      end
    end
  end
end
