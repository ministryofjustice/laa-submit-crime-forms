class Event
  class Decision < Event
    def self.build(claim:, previous_state:, comment:, current_user:)
      create(
        submitted_claim: claim,
        claim_version: claim.current_version,
        primary_user: current_user,
        details: {
          field: 'state',
          from: previous_state,
          to: claim.state,
          comment: comment
        }
      )
    end

    def title
      t("title.#{details['to']}", **title_options)
    end

    private

    def title_options
      { state: details['to'].tr('_', ' ') }
    end
  end
end
