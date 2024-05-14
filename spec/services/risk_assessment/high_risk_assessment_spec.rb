# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RiskAssessment::HighRiskAssessment do
  describe '#assess' do
    context 'returns true' do
      context 'when cost is over £5000' do
        let(:high_cost_claim) { create(:claim, :high_cost_disbursement) }

        it do
          expect(described_class.new(high_cost_claim)).to be_high_cost
          expect(described_class.new(high_cost_claim).assess).to be_truthy
        end
      end

      context 'when there is an assigned counsel' do
        let(:assigned_council_claim) { build(:claim, :with_assigned_council) }

        it do
          expect(described_class.new(assigned_council_claim)).to be_assigned_counsel
          expect(described_class.new(assigned_council_claim).assess).to be_truthy
        end
      end

      context 'when enhanced rates are claimed' do
        let(:enhanced_rates_claim) { build(:claim, :with_enhanced_rates) }

        it do
          expect(described_class.new(enhanced_rates_claim)).to be_enhancement_applied
          expect(described_class.new(enhanced_rates_claim).assess).to be_truthy
        end
      end

      context 'when there is an uplift' do
        let(:uplifted_claim) { build(:claim, :uplifted_work_item) }

        it do
          expect(described_class.new(uplifted_claim)).to be_uplift_applied
          expect(described_class.new(uplifted_claim).assess).to be_truthy
        end
      end

      context 'when there is workitem without an uplift' do
        let(:uplifted_claim) { build(:claim, :one_work_item) }

        it do
          expect(described_class.new(uplifted_claim)).not_to be_uplift_applied
          expect(described_class.new(uplifted_claim).assess).not_to be_truthy
        end
      end

      context 'when there is an extradition' do
        let(:extradition_claim) { build(:claim, :with_extradition) }

        it do
          expect(described_class.new(extradition_claim)).to be_extradition
          expect(described_class.new(extradition_claim).assess).to be_truthy
        end
      end

      context 'when a rep order is withdrawn' do
        let(:withdrawn_reporder_claim) { build(:claim, :with_rep_order_withdrawn) }

        it do
          expect(described_class.new(withdrawn_reporder_claim)).to be_rep_order_withdrawn
          expect(described_class.new(withdrawn_reporder_claim).assess).to be_truthy
        end
      end
    end

    context 'returns false' do
      let(:claim) { build(:claim) }

      it 'when cost is under £5000' do
        expect(described_class.new(claim)).not_to be_high_cost
      end

      it 'when there is not an assigned counsel' do
        expect(described_class.new(claim)).not_to be_assigned_counsel
      end

      it 'when enhanced rates are not claimed' do
        expect(described_class.new(claim)).not_to be_enhancement_applied
      end

      it 'when there is not an uplift' do
        expect(described_class.new(claim)).not_to be_uplift_applied
      end

      it 'when there is not an extradition' do
        expect(described_class.new(claim)).not_to be_extradition
      end

      it 'when a rep order is not withdrawn' do
        expect(described_class.new(claim)).not_to be_rep_order_withdrawn
      end
    end
  end
end
