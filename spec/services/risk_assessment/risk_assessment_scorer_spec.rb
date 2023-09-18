# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RiskAssessment::RiskAssessmentScorer do
  describe '#calculate' do
    context 'returns high risk' do
      let(:claim) { build(:claim, :with_assigned_council) }

      it do
        expect(described_class.calculate(claim)).to eq 'high'
      end
    end

    context 'returns medium risk' do
      let(:claim) { build(:claim, :medium_risk_work_item) }

      it do
        expect(described_class.calculate(claim)).to eq 'medium'
      end
    end

    context 'returns low risk' do
      let(:claim) { build(:claim) }

      it do
        expect(described_class.calculate(claim)).to eq 'low'
      end
    end
  end
end
