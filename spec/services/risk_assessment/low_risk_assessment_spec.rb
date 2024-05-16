# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RiskAssessment::LowRiskAssessment do
  describe '#assess' do
    context 'returns true' do
      context 'when prep and attendance is less than twice the advocacy' do
        let(:claim) { build(:claim) }

        it do
          expect(described_class.new(claim)).to be_prep_attendance_advocacy
          expect(described_class.new(claim).assess).to be_truthy
        end
      end

      context 'when prep time is less than double the advocacy time' do
        let(:claim) { build(:claim) }

        it do
          expect(described_class.new(claim)).to be_new_prep_advocacy
          expect(described_class.new(claim).assess).to be_truthy
        end
      end
    end

    context 'returns false' do
      let(:claim) { build(:claim, :medium_risk_work_item) }

      it 'when prep and attendance is more than twice the advocacy' do
        expect(described_class.new(claim)).not_to be_prep_attendance_advocacy
        expect(described_class.new(claim).assess).to be_falsey
      end

      it 'when prep time is more than double the advocacy time' do
        expect(described_class.new(claim)).not_to be_new_prep_advocacy
        expect(described_class.new(claim).assess).to be_falsey
      end
    end
  end

  describe '#new_prep_advocacy?' do
    let(:claim) do
      build(:claim,
            prosecution_evidence: 5,
            defence_statement: 7,
            number_of_witnesses: 3,
            time_spent: 24)
    end
    let(:low_risk_assessment) { described_class.new(claim) }

    it 'returns true if new preparation time and total attendance time are less than or equal to double the advocacy time' do
      expect(low_risk_assessment.new_prep_advocacy?).to be(true)
    end

    it 'returns false if new preparation time is greater than double the advocacy time' do
      allow(claim).to receive(:prosecution_evidence).and_return(100)
      expect(low_risk_assessment.new_prep_advocacy?).to be(false)
    end

    it 'returns false if total attendance time is greater than double the advocacy time' do
      allow(claim).to receive(:time_spent).and_return(100)
      expect(low_risk_assessment.new_prep_advocacy?).to be(false)
    end
  end
end
