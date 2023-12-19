class Event
  class ChangeRisk < Event
    def self.build(claim:, explanation:, previous_risk_level:, current_user:)
      create(
        submitted_claim: claim,
        claim_version: claim.current_version,
        primary_user: current_user,
        details: {
          field: 'risk',
          from: previous_risk_level,
          to: claim.risk,
          comment: explanation
        }
      )
    end

    def title_options
      { risk: details['to'] }
    end
  end
end
