# frozen_string_literal: true
require 'rails_helper'

RSpec.describe RiskAssessment::HighRiskAssessment do
  describe '#assess' do
    context 'returns true' do
      context 'when cost is over £5000' do
        let(:high_cost_claim) { build(:claim, :high_cost_disbursement) }

        it do
          expect(described_class.new(high_cost_claim).assess).to be_truthy
        end
      end

      context 'when there is an assigned counsel' do
        let(:assigned_council_claim) { build(:claim, :with_assigned_council) }

        it do
          expect(described_class.new(assigned_council_claim).assess).to be_truthy
        end
      end

      context 'when enhanced rates are claimed' do
        let(:enhanced_rates_claim) { build(:claim, :with_enhanced_rates) }

        it do
          expect(described_class.new(enhanced_rates_claim).assess).to be_truthy
        end
      end

      context 'when there is an uplift' do
        let(:uplifted_claim) { build(:claim, :uplifted_work_item) }

        it do
          expect(described_class.new(uplifted_claim).assess).to be_truthy
        end
      end

      context 'when there is an extradition' do
        let(:extradition_claim) { build(:claim, :with_extradition) }

        it do
          expect(described_class.new(extradition_claim).assess).to be_truthy
        end
      end

      context 'when a rep order is withdrawn' do
        let(:withdrawn_reporder_claim) { build(:claim, :with_rep_order_withdrawn) }

        it do
          expect(described_class.new(withdrawn_reporder_claim).assess).to be_truthy
        end
      end
    end
  end

end
