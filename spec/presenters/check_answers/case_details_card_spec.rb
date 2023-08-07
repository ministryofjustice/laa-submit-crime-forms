require 'rails_helper'

RSpec.describe CheckAnswers::CaseDetailsCard do
  subject { described_class.new(claim) }

  let(:claim) { build(:claim, :case_details, main_offence:, main_offence_date:) }
  # let(:form) do
  #   instance_double(Steps::CaseDetailsForm, main_offence:, main_offence_date:,
  #   assigned_counsel:, unassigned_counsel:, agent_instructed:, remitted_to_magistrate:)
  # end
  let(:main_offence) { 'Theft' }
  let(:main_offence_date) { Date.new(2023, 1, 1) }
  # let(:assigned_counsel) { YesNoAnswer::YES }
  # let(:unassigned_counsel) { YesNoAnswer::NO }
  # let(:agent_instructed) { YesNoAnswer::NO }
  # let(:remitted_to_magistrate) { YesNoAnswer::NO }

  # before do
  #   allow(Steps::CaseDetailsForm).to receive(:build).and_return(form)
  # end

  describe '#initialize' do
    it 'creates the data instance' do
      expect(Steps::CaseDetailsForm).to receive(:build).with(claim)
      subject
    end
  end

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Case details')
    end
  end

  describe '#row_data' do
    # rubocop:disable RSpec/ExampleLength
    it 'generates case detail rows' do
      expect(subject.row_data).to eq(
        [
          {
            head_key: 'main_offence',
            text: 'Theft'
          },
          {
            head_key: 'main_offence_date',
            text: '01 January 2023'
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
    # rubocop:enable RSpec/ExampleLength
  end
end
