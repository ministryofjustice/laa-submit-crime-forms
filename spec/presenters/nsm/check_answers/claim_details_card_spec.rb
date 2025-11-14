require 'rails_helper'

RSpec.describe Nsm::CheckAnswers::ClaimDetailsCard do
  subject { described_class.new(claim) }

  let(:claim) { build(:claim, :claim_details) }

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Claim details')
    end
  end

  describe '#row_data' do
    context 'when all boolean field have "Yes" values plus additional fields' do
      # rubocop:disable RSpec/ExampleLength
      it 'generates case detail rows' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'prosecution_evidence',
              text: 1
            },
            {
              head_key: 'defence_statement',
              text: 10
            },
            {
              head_key: 'number_of_witnesses',
              text: 2
            },
            {
              head_key: 'supplemental_claim',
              text: 'Yes'
            },
            {
              head_key: 'preparation_time',
              text: 'Yes'
            },
            {
              head_key: 'time_spent',
              text: '2 hours 1 minute'
            },
            {
              head_key: 'work_before',
              text: 'Yes'
            },
            {
              head_key: 'work_before_date',
              text: '1 December 2020'
            },
            {
              head_key: 'work_after',
              text: 'Yes'
            },
            {
              head_key: 'work_after_date',
              text: '1 January 2020'
            },
            {
              head_key: 'work_completed_date',
              text: '2 January 2020'
            },
            {
              head_key: 'wasted_costs',
              text: 'Yes'
            },
          ]
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when all boolean field have "No" values' do
      let(:claim) { build(:claim, :claim_details, :claim_details_no) }

      # rubocop:disable RSpec/ExampleLength
      it 'generates case detail rows' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'prosecution_evidence',
              text: 1
            },
            {
              head_key: 'defence_statement',
              text: 10
            },
            {
              head_key: 'number_of_witnesses',
              text: 2
            },
            {
              head_key: 'supplemental_claim',
              text: 'No'
            },
            {
              head_key: 'preparation_time',
              text: 'No'
            },
            {
              head_key: 'work_before',
              text: 'No'
            },
            {
              head_key: 'work_after',
              text: 'No'
            },
            {
              head_key: 'work_completed_date',
              text: '2 January 2020'
            },
            {
              head_key: 'wasted_costs',
              text: 'No'
            },
          ]
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'all fields missing' do
      let(:claim) { build(:claim) }

      # rubocop:disable RSpec/ExampleLength
      it 'generates case detail rows' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'prosecution_evidence',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'defence_statement',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'number_of_witnesses',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'preparation_time',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'work_before',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'work_after',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'work_completed_date',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'wasted_costs',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            }
          ]
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'all boolean field with yes values, but missing additional data' do
      let(:claim) { build(:claim, :claim_details, time_spent: nil, work_before_date: nil, work_after_date: nil) }

      # rubocop:disable RSpec/ExampleLength
      it 'generates case detail rows' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'prosecution_evidence',
              text: 1
            },
            {
              head_key: 'defence_statement',
              text: 10
            },
            {
              head_key: 'number_of_witnesses',
              text: 2
            },
            {
              head_key: 'supplemental_claim',
              text: 'Yes'
            },
            {
              head_key: 'preparation_time',
              text: 'Yes'
            },
            {
              head_key: 'time_spent',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'work_before',
              text: 'Yes'
            },
            {
              head_key: 'work_before_date',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'work_after',
              text: 'Yes'
            },
            {
              head_key: 'work_after_date',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'work_completed_date',
              text: '2 January 2020'
            },
            {
              head_key: 'wasted_costs',
              text: 'Yes'
            }
          ]
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end
  end
end
