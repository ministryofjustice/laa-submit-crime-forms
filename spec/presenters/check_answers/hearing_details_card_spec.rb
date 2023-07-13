require 'rails_helper'

RSpec.describe CheckAnswers::HearingDetailsCard do
  subject { described_class.new(claim) }

  let(:claim) { instance_double(Claim) }
  let(:hearing_details_form) do
    instance_double(Steps::HearingDetailsForm, first_hearing_date:, court:,
       number_of_hearing:, youth_count:, in_area:, hearing_outcome:, matter_type:)
  end

  let(:first_hearing_date) { Date.new(2023, 3, 1) }
  let(:number_of_hearing) { 1 }
  let(:youth_count) { YesNoAnswer::NO }
  let(:in_area) { YesNoAnswer::YES }
  let(:court) { 'A Court' }
  let(:hearing_outcome) { 'CP01' }
  let(:matter_type) { '1' }

  before do
    allow(Steps::HearingDetailsForm).to receive(:build).and_return(hearing_details_form)
  end

  describe '#initialize' do
    it 'creates the data instance' do
      subject
      expect(Steps::HearingDetailsForm).to have_received(:build).with(claim)
    end
  end

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Hearing Details')
    end
  end

  describe '#route_path' do
    it 'is correct route' do
      expect(subject.route_path).to eq('hearing_details')
    end
  end

  describe '#rows' do
    it 'generates hearing details rows' do
      expect(subject.rows).to eq(
        [
          {
            key: { text: 'Date of first hearing', classes: 'govuk-summary-list__value-width-50' },
            value: { text: '01 March 2023' }
          },
          {
            key: { text: 'Number of hearings', classes: 'govuk-summary-list__value-width-50' },
            value: { text: 1 }
          },
          {
            key: { text: 'Youth court', classes: 'govuk-summary-list__value-width-50' },
            value: { text: 'No' }
          },
          {
            key: { text: 'Magistrates court in designated area', classes: 'govuk-summary-list__value-width-50' },
            value: { text: 'Yes - A Court' }
          },
          {
            key: { text: 'Hearing outcome', classes: 'govuk-summary-list__value-width-50' },
            value: { text: 'Arrest warrant issued/adjourned indefinitely' }
          },
          {
            key: { text: 'Matter type', classes: 'govuk-summary-list__value-width-50' },
            value: { text: 'Offences against the person' }
          }
        ]
      )
    end
  end
end
