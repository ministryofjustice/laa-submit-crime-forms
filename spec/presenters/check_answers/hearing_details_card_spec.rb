require 'rails_helper'

RSpec.describe CheckAnswers::HearingDetailsCard do
  subject { described_class.new(claim) }

  let(:claim) { build(:claim, :hearing_details) }

  describe '#initialize' do
    it 'creates the data instance' do
      expect(Steps::HearingDetailsForm).to receive(:build).with(claim)
      subject
    end
  end

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Hearing details')
    end
  end

  describe '#row_data' do
    it 'generates hearing details rows' do
      expect(subject.row_data).to eq(
        [
          {
            head_key: 'hearing_date',
            text: '01 March 2023'
          },
          {
            head_key: 'number_of_hearing',
            text: 1
          },
          {
            head_key: 'court',
            text: 'A Court'
          },
          {
            head_key: 'in_area',
            text: 'Yes'
          },
          {
            head_key: 'youth_court',
            text: 'No'
          },
          {
            head_key: 'hearing_outcome',
            text: 'Arrest warrant issued/adjourned indefinitely'
          },
          {
            head_key: 'matter_type',
            text: 'Offences against the person'
          }
        ]
      )
    end

    context 'when no data exists' do
      let(:claim) { build(:claim) }

      it 'generates missing data elements for hearing detail rows' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'hearing_date',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'number_of_hearing',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'court',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'in_area',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'youth_court',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'hearing_outcome',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'matter_type',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            }
          ]
        )
      end
    end
  end
end
