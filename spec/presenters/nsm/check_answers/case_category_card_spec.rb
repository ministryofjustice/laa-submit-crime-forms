require 'rails_helper'

RSpec.describe Nsm::CheckAnswers::CaseCategoryCard do
  subject { described_class.new(claim) }

  let(:claim) do
    build(:claim,
          plea:,
          plea_category:,
          include_youth_court_fee:,
          arrest_warrant_date:,
          case_outcome_other_info:,
          change_solicitor_date:)
  end

  let(:arrest_warrant_date) { nil }
  let(:change_solicitor_date) { nil }
  let(:plea) { nil }
  let(:plea_category) { nil }
  let(:include_youth_court_fee) { nil }
  let(:case_outcome_other_info) { nil }

  describe '#initialize' do
    it 'creates the data instance' do
      expect(Nsm::Steps::CaseCategoryForm).to receive(:build).with(claim)
      expect(Nsm::Steps::CaseOutcomeForm).to receive(:build).with(claim)
      expect(Nsm::Steps::YouthCourtClaimAdditionalFeeForm).to receive(:build).with(claim)
      subject
    end
  end

  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Case disposal')
    end
  end

  context 'when plea is guilty' do
    let(:plea_category) { :category_1a }
    let(:plea) { :guilty }
    let(:include_youth_court_fee) { true }

    it 'returns the correct row_data' do
      expect(subject.row_data).to eq(
        [
          {
            head_key: :category_1a,
            text: 'Guilty plea'
          },
          {
            head_key: :additional_fee,
            text: 'Youth court fee claimed'
          }
        ]
      )
    end
  end

  context 'case outcome is other' do
    let(:plea_category) { :category_2a }
    let(:plea) { :other }
    let(:include_youth_court_fee) { false }
    let(:case_outcome_other_info) { 'test' }

    it 'returns case category and other details' do
      expect(subject.row_data).to eq(
        [
          {
            head_key: :category_2a,
            text: 'Other: test'
          },
          {
            head_key: :additional_fee,
            text: 'Youth court fee not claimed'
          }
        ]
      )
    end
  end

  context 'when plea is guilty - ARREST_WARRANT' do
    let(:arrest_warrant_date) { Date.new(2023, 3, 1) }
    let(:plea_category) { :category_1a }
    let(:plea) { :arrest_warrant }
    let(:include_youth_court_fee) { false }

    it 'returns the correct row_data' do
      expect(subject.row_data).to eq(
        [
          {
            head_key: :category_1a,
            text: 'Warrant of arrest'
          },
          {
            head_key: :additional_fee,
            text: 'Youth court fee not claimed'
          },
          {
            head_key: :arrest_warrant_date,
            text: '1 March 2023'
          },
        ]
      )
    end
  end

  context 'when plea is guilty - CHANGE OF SOLICITOR' do
    let(:change_solicitor_date) { Date.new(2023, 3, 1) }
    let(:plea_category) { :category_1a }
    let(:plea) { :change_solicitor }
    let(:include_youth_court_fee) { false }

    it 'returns the correct row_data' do
      expect(subject.row_data).to eq(
        [
          {
            head_key: :category_1a,
            text: 'Change of solicitor'
          },
          {
            head_key: :additional_fee,
            text: 'Youth court fee not claimed'
          },
          {
            head_key: :change_solicitor_date,
            text: '1 March 2023'
          },
        ]
      )
    end
  end

  context 'when plea is not guilty' do
    let(:plea_category) { :category_1a }
    let(:plea) { :not_guilty }
    let(:include_youth_court_fee) { true }

    it 'returns the correct row_data' do
      expect(subject.row_data).to eq(
        [
          {
            head_key: :category_1a,
            text: 'Not guilty plea'
          },
          {
            head_key: :additional_fee,
            text: 'Youth court fee claimed'
          }
        ]
      )
    end
  end

  context 'when plea is not set' do
    let(:plea_category) { nil }

    it 'returns the correct row_data' do
      expect(subject.row_data).to eq(
        [
          {
            head_key: :pending,
            text: '<strong class="govuk-tag govuk-tag--red">Incomplete</strong>'
          }
        ]
      )
    end
  end
end
