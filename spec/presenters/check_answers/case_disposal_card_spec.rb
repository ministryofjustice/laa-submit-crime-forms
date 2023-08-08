require 'rails_helper'

RSpec.describe CheckAnswers::CaseDisposalCard do
  subject { described_class.new(claim) }

  let(:claim) { build(:claim, plea:, arrest_warrant_date:, cracked_trial_date:) }

  let(:arrest_warrant_date) { nil }
  let(:cracked_trial_date) { nil }
  let(:plea) { nil }

  describe '#initialize' do
    it 'creates the data instance' do
      expect(Steps::CaseDisposalForm).to receive(:build).with(claim)
      subject
    end
  end

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Case disposal')
    end
  end

  context 'when plea is guilty' do
    let(:plea) { PleaOptions::GUILTY }

    it 'returns the correct row_data' do
      expect(subject.row_data).to eq(
        [
          {
            head_key: :guilty_pleas,
            text: 'Guilty plea'
          },
        ]
      )
    end
  end

  context 'when plea is guilty - ARREST_WARRANT' do
    let(:arrest_warrant_date) { Date.new(2023, 3, 1) }
    let(:plea) { PleaOptions::ARREST_WARRANT }

    it 'returns the correct row_data' do
      expect(subject.row_data).to eq(
        [
          {
            head_key: :guilty_pleas,
            text: 'Warrant of arrest'
          },
          {
            head_key: 'arrest_warrant_date',
            text: '01 March 2023'
          }
        ]
      )
    end
  end

  context 'when plea is not guilty' do
    let(:plea) { PleaOptions::NOT_GUILTY }

    it 'returns the correct row_data' do
      expect(subject.row_data).to eq(
        [
          {
            head_key: :not_guilty_pleas,
            text: 'Not guilty plea'
          },
        ]
      )
    end
  end

  context 'when plea is not guilty - CRACKED_TRIAL' do
    let(:cracked_trial_date) { Date.new(2023, 3, 1) }
    let(:plea) { PleaOptions::CRACKED_TRIAL }

    it 'returns the correct row_data' do
      expect(subject.row_data).to eq(
        [
          {
            head_key: :not_guilty_pleas,
            text: 'Cracked trial'
          },
          {
            head_key: 'cracked_trial_date',
            text: '01 March 2023'
          }
        ]
      )
    end
  end

  context 'when plea is not set' do
    it 'returns the correct row_data' do
      expect(subject.row_data).to eq(
        [
          {
            head_key: :pending,
            text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
          },
        ]
      )
    end
  end

  describe '#find_key_by_value' do
    it 'returns the correct key for a valid value' do
      key = subject.find_key_by_value('arrest_warrant')
      expect(key).to eq(:guilty_pleas)
    end

    it 'returns nil for an invalid value' do
      key = subject.find_key_by_value('invalid_value')
      expect(key).to be_nil
    end
  end
end
