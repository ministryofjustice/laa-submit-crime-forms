class Event
  class Unassignment < Event
    belongs_to :secondary_user, optional: true, class_name: 'User'

    def self.build(claim:, user:, current_user:, comment:)
      create(
        submitted_claim: claim,
        primary_user: user,
        secondary_user: user == current_user ? nil : current_user,
        claim_version: claim.current_version,
        details: {
          comment:
        }
      )
    end

    def title
      if secondary_user_id
        t('title.secondary', display_name: secondary_user.display_name)
      else
        t('title.self')
      end
    end
  end
end
