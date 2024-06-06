# frozen_string_literal: true

module RiskAssessment
  class HighRiskAssessment
    def initialize(claim)
      @claim = claim

      @items = {
        work_items: Nsm::CostSummary::WorkItems.new(@claim.work_items, @claim),
        letters_calls: Nsm::CostSummary::LettersCalls.new(@claim),
        disbursements: Nsm::CostSummary::Disbursements.new(@claim.disbursements.by_age, @claim)
      }
    end

    def assess
      high_cost? || counsel_assigned? || uplift_applied? || extradition? || rep_order_withdrawn?
    end

    def high_cost?
      @items.values.filter_map(&:total_cost).sum > 5000
    end

    def counsel_assigned?
      [@claim.assigned_counsel, @claim.unassigned_counsel, @claim.agent_instructed].include?('yes')
    end

    def uplift_applied?
      @items[:work_items].work_items.any?(&:apply_uplift) || @claim.apply_calls_uplift || @claim.apply_letters_uplift
    end

    def extradition?
      @claim.reasons_for_claim.include? 'extradition'
    end

    def rep_order_withdrawn?
      @claim.reasons_for_claim.include? 'representation_order_withdrawn'
    end
  end
end
