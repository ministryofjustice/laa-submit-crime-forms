# frozen_string_literal: true

module RiskAssessment
  class HighRiskAssessment
    def initialize(claim)
      @claim = claim

      @items = {
        work_items: CostSummary::WorkItems.new(@claim.work_items, @claim),
        letters_calls: CostSummary::LettersCalls.new(@claim),
        disbursements: CostSummary::Disbursements.new(@claim.disbursements.by_age, @claim)
      }
    end

    def assess
      high_cost? || assigned_counsel? || enhancement_applied? || uplift_applied? || extradition? || rep_order_withdrawn?
    end

    def high_cost?
      @items.values.filter_map(&:total_cost).sum > 5000
    end

    def assigned_counsel?
      @claim.assigned_counsel == 'yes'
    end

    def enhancement_applied?
      @claim.reasons_for_claim.include? 'enhanced_rates_claimed'
    end

    def uplift_applied?
      @items[:work_items].work_item_forms.filter_map(&:uplift).any?
    end

    def extradition?
      @claim.reasons_for_claim.include? 'extradition'
    end

    def rep_order_withdrawn?
      @claim.reasons_for_claim.include? 'representation_order_withdrawn'
    end
  end
end
