# frozen_string_literal: true

module RiskAssessment
  class RiskAssessmentScorer
    RISK_LEVELS = {
      high: 'high',
      medium: 'medium',
      low: 'low'
    }.freeze
    def self.calculate(claim)
      return RISK_LEVELS[:high] if high_risk? claim

      return RISK_LEVELS[:low] if low_risk? claim

      RISK_LEVELS[:medium]
    end

    def self.high_risk?(claim)
      HighRiskAssessment.new(claim).assess
    end

    def self.low_risk?(claim)
      LowRiskAssessment.new(claim).assess
    end
  end
end
