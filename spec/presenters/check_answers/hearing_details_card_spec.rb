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
      expect(subject.title).to eq('Hearing details')
    end
  end

  describe '#row_data' do
    # rubocop:disable RSpec/ExampleLength
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
            head_key: 'youth_count',
            text: 'No'
          },
          {
            head_key: 'in_area',
            text: 'Yes - A Court'
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
    # rubocop:enable RSpec/ExampleLength
  end
end
