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
end
