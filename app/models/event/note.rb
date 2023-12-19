class Event
  class Note < Event
    def self.build(claim:, note:, current_user:)
      create(
        submitted_claim: claim,
        claim_version: claim.current_version,
        primary_user: current_user,
        details: {
          comment: note
        }
      )
    end
  end
end
