require 'rails_helper'

RSpec.describe CheckAnswers::ClaimDetailsCard do
  subject { described_class.new(claim) }

  let(:claim) { build(:claim, :claim_details) }

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Claim details')
    end
  end

  describe '#row_data' do
    # rubocop:disable RSpec/ExampleLength
    context 'all boolean field with yes values and additional fields' do
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
              text: 'Yes - 2 Hrs 1 Min'
            },
            {
              head_key: 'work_before',
              text: 'Yes - 01 December 2020'
            },
            {
              head_key: 'work_after',
              text: 'Yes - 01 January 2020'
            }
          ]
        )
      end
    end

    context 'all boolean field with no values' do
      let(:claim) { build(:claim, :claim_details, :claim_details_no) }

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
            }
          ]
        )
      end
    end

    context 'all fields missing' do
      let(:claim) { build(:claim) }

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
              head_key: 'supplemental_claim',
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
            }
          ]
        )
      end
    end

    context 'all boolean field with yes values, but missing addition data' do
      let(:claim) { build(:claim, :claim_details, time_spent: nil, work_before_date: nil, work_after_date: nil) }

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
              text: 'Yes - <strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'work_before',
              text: 'Yes - <strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'work_after',
              text: 'Yes - <strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            }
          ]
        )
      end
    end
    # rubocop:enable RSpec/ExampleLength
  end
end
