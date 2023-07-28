require 'rails_helper'

RSpec.describe CheckAnswers::ClaimDetailsCard do
  subject { described_class.new(claim) }

  let(:claim) { instance_double(Claim) }
  let(:form) do
    instance_double(Steps::ClaimDetailsForm, prosecution_evidence:,
    defence_statement:, number_of_witnesses:, supplemental_claim:,
    preparation_time:, time_spent:, work_before:, work_before_date:,
    work_after:, work_after_date:)
  end
  let(:prosecution_evidence) { 1 }
  let(:defence_statement) { 10 }
  let(:number_of_witnesses) { 2 }
  let(:supplemental_claim) { YesNoAnswer::YES }
  let(:preparation_time) { true }
  let(:time_spent) { IntegerTimePeriod.new(121) }
  let(:work_before) { true }
  let(:work_before_date) { Date.new(2020, 12, 1) }
  let(:work_after) { true }
  let(:work_after_date) { Date.new(2020, 1, 1) }

  before do
    allow(Steps::ClaimDetailsForm).to receive(:build).and_return(form)
  end

  describe '#initialize' do
    it 'creates the data instance' do
      subject
      expect(Steps::ClaimDetailsForm).to have_received(:build).with(claim)
    end
  end

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Claim details')
    end
  end

  describe '#work_before' do
    context 'Work before set to No' do
      let(:work_before) { false }

      it 'generates text indicating No' do
        expect(subject.work_before).to eq('No')
      end
    end

    context 'Work before set to Yes' do
      let(:work_before) { true }

      it 'generates text indicating Yes with date' do
        expect(subject.work_before).to eq('Yes - 01 December 2020')
      end
    end
  end

  describe '#row_data' do
    # rubocop:disable RSpec/ExampleLength
    context 'Work before order and work last granted' do
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

    context 'No work before order or work last granted' do
      let(:work_before) { false }
      let(:work_after) { false }

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
    # rubocop:enable RSpec/ExampleLength
  end
end
