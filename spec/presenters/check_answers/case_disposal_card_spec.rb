require 'rails_helper'

RSpec.describe CheckAnswers::CaseDisposalCard do
  subject { described_class.new(claim) }

  # let(:claim) do
  #   Claim.create!(plea: 'arrest_warrant', cracked_trial_date: date.new(2019, 1, 1),
  #                 arrest_warrent_date: date.new(2020, 1, 1))
  # end

  let(:claim) { instance_double(Claim) }

  let(:form) do
    instance_double(Steps::CaseDisposalForm, plea:, arrest_warrent_date:, cracked_trial_date:)
  end

  let(:arrest_warrent_date) { Date.new(2023, 3, 1) }
  let(:cracked_trial_date) { nil }
  let(:plea) { 'arrest_warrent' }

  before do
    allow(Steps::CaseDisposalForm).to receive(:build).and_return(form)
  end

  describe '#initialize' do
    it 'creates the data instance' do
      subject
      expect(Steps::CaseDisposalForm).to have_received(:build).with(claim)
    end
  end

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Case Disposal')
    end
  end

  describe '#route_path' do
    it 'is correct route' do
      expect(subject.route_path).to eq('case_disposal')
    end
  end

  describe 'when plea is guilty' do
    it 'returns the correct row_data' do
      expect(subject.row_data).to eq(
        [
          {
            head_key: :guilty_pleas,
            text: 'arrest_warrent'
          },
          {
            head_key: :cracked_trial_date,
            text: 'arrest_warrent'
          }
        ]
      )
    end
  end

  describe '#find_key_by_value' do
    it 'returns the correct key for a valid value' do
      key = find_key_by_value('arrest_warrent')
      expect(key).to eq(:guilty_pleas)
    end

    it 'returns nil for an invalid value' do
      key = find_key_by_value('invalid_value')
      expect(key).to be_nil
    end
  end

  describe '#transform_value' do
    it 'transforms the value correctly' do
      transformed_value = transform_value('arrest_warrent')

      expect(transformed_value).to eq('Arrest warrant')
    end

    it 'transforms a single-word value correctly' do
      transformed_value = transform_value('arrest_warrent')
      expect(transformed_value).to eq('Arrest warrant')
    end

    it 'handles empty input correctly' do
      transformed_value = transform_value('')
      expect(transformed_value).to eq('')
    end

    it 'handles nil input correctly' do
      transformed_value = transform_value(nil)
      expect(transformed_value).to eq('')
    end
  end
end
