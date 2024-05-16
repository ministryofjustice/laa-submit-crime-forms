# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RiskAssessment::RiskAssessmentScorer do
  let(:fee_earner_initial) { Faker::Alphanumeric.alphanumeric(number: 2, min_alpha: 2, min_numeric: 0) }

  describe '#calculate' do
    context 'returns high risk' do
      let(:claim) { build(:claim, :with_assigned_council) }

      it do
        expect(described_class.calculate(claim)).to eq('high')
      end
    end

    context 'returns medium risk' do
      let(:claim) do
        build(:claim,
              prosecution_evidence: 50,
              defence_statement: 1,
              number_of_witnesses: 1,
              work_items: [
                build(:work_item, work_type: WorkTypes::PREPARATION,
                  time_spent: '23',
                  completed_on: Time.zone.today,
                  fee_earner: fee_earner_initial),
                build(:work_item, work_type: WorkTypes::ATTENDANCE_WITHOUT_COUNSEL,
                  time_spent: '40',
                  completed_on: Time.zone.yesterday,
                  fee_earner: fee_earner_initial),
                build(:work_item, work_type: WorkTypes::ADVOCACY,
                  time_spent: '26',
                  completed_on: Time.zone.yesterday,
                  fee_earner: fee_earner_initial),
                build(:work_item, work_type: WorkTypes::TRAVEL,
                  time_spent: '156',
                  completed_on: Time.zone.yesterday,
                  fee_earner: fee_earner_initial),
              ])
      end

      it do
        expect(described_class.calculate(claim)).to eq('medium')
      end
    end

    context 'returns low risk' do
      let(:claim) do
        build(:claim,
              prosecution_evidence: 50,
              defence_statement: 1,
              number_of_witnesses: 1,
              time_spent: 24,
              work_items: [
                build(:work_item, work_type: WorkTypes::PREPARATION,
                  time_spent: '552',
                  completed_on: Time.zone.today,
                  fee_earner: fee_earner_initial),
                build(:work_item, work_type: WorkTypes::ATTENDANCE_WITHOUT_COUNSEL,
                  time_spent: '282',
                  completed_on: Time.zone.yesterday,
                  fee_earner: fee_earner_initial),
                build(:work_item, work_type: WorkTypes::ADVOCACY,
                  time_spent: '246',
                  completed_on: Time.zone.yesterday,
                  fee_earner: fee_earner_initial),
                build(:work_item, work_type: WorkTypes::TRAVEL,
                  time_spent: '156',
                  completed_on: Time.zone.yesterday,
                  fee_earner: fee_earner_initial),
              ])
      end

      it do
        expect(described_class.calculate(claim)).to eq('low')
      end
    end
  end
end
