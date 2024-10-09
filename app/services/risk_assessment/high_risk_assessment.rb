# frozen_string_literal: true

module RiskAssessment
  class HighRiskAssessment
    HIGH_RISK_THRESHOLD = 5000

    def initialize(claim)
      @claim = claim

      @summary = Nsm::CheckAnswers::CostSummaryCard.new(claim)
    end

    def assess
      high_cost? || counsel_assigned? || enhanced_rates_claimed? || extradition? || rep_order_withdrawn?
    end

    def high_cost?
      profit_cost_summary = @summary.table_fields(formatted: false).find { _1[:name] == 'profit_costs' }
      profit_cost_summary[:gross_cost] >= HIGH_RISK_THRESHOLD
    end

    def counsel_assigned?
      [@claim.assigned_counsel, @claim.unassigned_counsel, @claim.agent_instructed].include?('yes')
    end

    def enhanced_rates_claimed?
      @claim.reasons_for_claim.include? 'enhanced_rates_claimed'
    end

    def extradition?
      @claim.reasons_for_claim.include? 'extradition'
    end

    def rep_order_withdrawn?
      @claim.reasons_for_claim.include? 'representation_order_withdrawn'
    end
  end
end
