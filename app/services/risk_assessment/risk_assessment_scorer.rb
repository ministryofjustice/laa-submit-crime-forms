# frozen_string_literal: true

module RiskAssessment
  class RiskAssessmentScorer
    def self.calculate(_claim)
      return 'high' if high_risk?

      return 'low' if low_risk?

      'medium'
    end

    def high_risk?(claim)
      HighRiskAssessment.assess(claim)
    end

    def low_risk?(claim)
      LowRiskAssessment.assess(claim)
    end
  end
end
