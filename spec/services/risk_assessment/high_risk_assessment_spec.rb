# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RiskAssessment::HighRiskAssessment do
  describe '#assess' do
    subject(:assessment) { described_class.new(claim).assess }

    let(:claim) { create(:claim, :one_work_item) }

    it 'returns false when no clauses are triggered' do
      expect(assessment).to be_falsey
    end

    context 'when cost is over £5000' do
      before { create(:disbursement, :valid_high_cost, claim:) }

      it 'returns true' do
        expect(assessment).to be_truthy
      end
    end

    context 'when there is an assigned counsel' do
      before { claim.assigned_counsel = 'yes' }

      it 'returns true' do
        expect(assessment).to be_truthy
      end
    end

    context 'when there is an unassigned counsel' do
      before { claim.unassigned_counsel = 'yes' }

      it 'returns true' do
        expect(assessment).to be_truthy
      end
    end

    context 'when there is an instructed agent' do
      before { claim.agent_instructed = 'yes' }

      it 'returns true' do
        expect(assessment).to be_truthy
      end
    end

    context 'when enhanced rates are claimed' do
      before { claim.reasons_for_claim = [ReasonForClaim::ENHANCED_RATES_CLAIMED.to_s] }

      it 'returns false by default' do
        expect(assessment).to be_falsey
      end

      context 'when there is an uplift to a work item' do
        before { claim.work_items.first.update(uplift: 100) }

        it 'returns true' do
          expect(assessment).to be_truthy
        end
      end

      context 'when there is a letters uplift' do
        before { claim.letters_uplift = 100 }

        it 'returns true' do
          expect(assessment).to be_truthy
        end
      end

      context 'when there is a calls uplift' do
        before { claim.calls_uplift = 100 }

        it 'returns true' do
          expect(assessment).to be_truthy
        end
      end
    end

    context 'when there is an extradition' do
      before { claim.reasons_for_claim = [ReasonForClaim::EXTRADITION.to_s] }

      it 'returns true' do
        expect(assessment).to be_truthy
      end
    end

    context 'when a rep order is withdrawn' do
      before { claim.reasons_for_claim = [ReasonForClaim::REPRESENTATION_ORDER_WITHDRAWN.to_s] }

      it 'returns true' do
        expect(assessment).to be_truthy
      end
    end
  end
end
