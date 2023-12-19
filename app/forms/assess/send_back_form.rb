module Assess
  class SendBackForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    STATES = [
      FURTHER_INFO = 'further_info'.freeze,
      PROVIDER_REQUESTED = 'provider_requested'.freeze,
    ].freeze

    attribute :state
    attribute :comment
    attribute :current_user
    attribute :claim

    validates :claim, presence: true
    validates :state, inclusion: { in: STATES }
    validates :comment, presence: true, if: -> { state.present? }

    def save
      return false unless valid?

      previous_state = claim.state
      SubmittedClaim.transaction do
        claim.update!(state:)
        Event::SendBack.build(claim:, comment:, previous_state:, current_user:)
        update_provider_claim
      end

      true
    end

    def update_provider_claim
      Claim.find(claim.id).update!(status: claim.state, app_store_updated_at: DateTime.current)
    end
  end
end
