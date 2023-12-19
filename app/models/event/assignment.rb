class Event
  class Assignment < Event
    def self.build(claim:, current_user:)
      create(
        submitted_claim: claim,
        primary_user: current_user,
        claim_version: claim.current_version
      )
    end
  end
end
