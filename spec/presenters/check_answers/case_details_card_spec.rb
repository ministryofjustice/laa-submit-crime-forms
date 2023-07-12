require 'rails_helper'

RSpec.describe CheckAnswers::CaseDetailsCard do
  subject { described_class.new(claim) }

  let(:claim) { instance_double(Claim) }
  let(:form) do
    instance_double(Steps::CaseDetailsForm, main_offence:, main_offence_date:,
    assigned_counsel:, unassigned_counsel:, agent_instructed:, remitted_to_magistrate:)
  end
  let(:main_offence) { 'Theft' }
  let(:main_offence_date) { Date.new(2023, 1, 1) }
  let(:assigned_counsel) { YesNoAnswer::YES }
  let(:unassigned_counsel) { YesNoAnswer::NO }
  let(:agent_instructed) { YesNoAnswer::NO }
  let(:remitted_to_magistrate) { YesNoAnswer::NO }

  before do
    allow(Steps::CaseDetailsForm).to receive(:build).and_return(form)
  end

  describe '#initialize' do
    it 'creates the data instance' do
      subject
      expect(Steps::CaseDetailsForm).to have_received(:build).with(claim)
    end
  end

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Case Details')
    end
  end

  describe '#route_path' do
    it 'is correct route' do
      expect(subject.route_path).to eq('case_details')
    end
  end

  describe '#rows' do
    it 'generates case detail rows' do
      expect(subject.rows).to eq(
        [
          {
            key: { text: 'Main offence name', classes: 'govuk-summary-list__value-width-50' },
            value: { text: 'Theft' }
          },
          {
            key: { text: 'Offence date', classes: 'govuk-summary-list__value-width-50' },
            value: { text: '01 January 2023' }
          },
          {
            key: { text: 'Assigned counsel', classes: 'govuk-summary-list__value-width-50' },
            value: { text: 'Yes' }
          },
          {
            key: { text: 'Unassigned counsel', classes: 'govuk-summary-list__value-width-50' },
            value: { text: 'No' }
          },
          {
            key: { text: 'Instructed Agent', classes: 'govuk-summary-list__value-width-50' },
            value: { text: 'No' }
          },
          {
            key: { text: 'Remittal', classes: 'govuk-summary-list__value-width-50' },
            value: { text: 'No' }
          }
        ]
      )
    end
  end
end
