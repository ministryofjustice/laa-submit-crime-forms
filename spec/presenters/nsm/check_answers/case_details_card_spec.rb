require 'rails_helper'

RSpec.describe Nsm::CheckAnswers::CaseDetailsCard do
  subject { described_class.new(claim) }

  let(:claim) { build(:claim, :case_details, main_offence:, main_offence_date:) }
  let(:main_offence) { 'Theft' }
  let(:main_offence_date) { Date.new(2023, 1, 1) }

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Case details')
    end
  end

  describe '#row_data' do
    it 'generates case detail rows with no remittal' do
      expect(subject.row_data).to match(
        [
          {
            head_key: 'main_offence',
            text: 'Theft'
          },
          {
            head_key: 'main_offence_date',
            text: '1 January 2023'
          },
          {
            head_key: 'assigned_counsel',
            text: 'No'
          },
          {
            head_key: 'unassigned_counsel',
            text: 'No'
          },
          {
            head_key: 'agent_instructed',
            text: 'No'
          },
          {
            head_key: 'remitted_to_magistrate',
            text: 'No'
          }
        ]
      )
    end

    context 'when remitted to magistrate is yes' do
      let(:claim) do
        build(:claim, :case_details, :with_remittal, main_offence:, main_offence_date:, remitted_to_magistrate_date:)
      end
      let(:remitted_to_magistrate_date) { Date.new(2023, 6, 30) }

      it 'generates case detail rows with remittal' do
        expect(subject.row_data).to match(
          [
            {
              head_key: 'main_offence',
              text: 'Theft'
            },
            {
              head_key: 'main_offence_date',
              text: '1 January 2023'
            },
            {
              head_key: 'assigned_counsel',
              text: 'No'
            },
            {
              head_key: 'unassigned_counsel',
              text: 'No'
            },
            {
              head_key: 'agent_instructed',
              text: 'No'
            },
            {
              head_key: 'remitted_to_magistrate',
              text: 'Yes'
            },
            {
              head_key: 'remitted_to_magistrate_date',
              text: '30 June 2023'
            }
          ]
        )
      end
    end

    context 'when no data exists' do
      let(:claim) { build(:claim) }

      it 'generates missing data elements for case detail rows' do
        expect(subject.row_data).to eq(
          [
            {
              head_key: 'main_offence',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'main_offence_date',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'assigned_counsel',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'unassigned_counsel',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'agent_instructed',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            },
            {
              head_key: 'remitted_to_magistrate',
              text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
            }
          ]
        )
      end
    end
  end
end
