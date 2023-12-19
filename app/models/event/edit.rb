class Event
  class Edit < Event
    def self.build(claim:, linked:, details:, current_user:)
      create(
        submitted_claim: claim,
        claim_version: claim.current_version,
        primary_user: current_user,
        linked_type: linked.fetch(:type),
        linked_id: linked.fetch(:id, nil),
        details: details,
      )
    end
  end
end
