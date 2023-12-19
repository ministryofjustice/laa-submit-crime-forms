class Event
  class NewVersion < Event
    def self.build(claim:)
      create(submitted_claim: claim, claim_version: claim.current_version)
    end
  end
end
