# frozen_string_literal: true

module RiskAssessment
  class RiskAssessmentScorer
    def self.calculate(claim)
      return 'high' if high_risk? claim

      return 'low' if low_risk? claim

      'medium'
    end

    def self.high_risk?(claim)
      HighRiskAssessment.new(claim).assess
    end

    def self.low_risk?(claim)
      LowRiskAssessment.new(claim).assess
    end
  end
end
