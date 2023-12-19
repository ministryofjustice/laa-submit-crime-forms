class SubmittedClaim < ApplicationRecord
  has_many :events, dependent: :destroy
  has_many :assignments, dependent: :destroy

  validates :risk, inclusion: { in: %w[low medium high] }
  validates :current_version, numericality: { only_integer: true, greater_than: 0 }

  scope :pending_decision, -> { where.not(state: Assess::MakeDecisionForm::STATES) }
  scope :decision_made, -> { where(state: Assess::MakeDecisionForm::STATES) }
  scope :your_claims, lambda { |user|
    pending_decision
      .joins(:assignments)
      .where(assignments: { user_id: user.id })
  }
  scope :unassigned_claims, lambda { |user|
    pending_decision
      .where.missing(:assignments)
      .where.not(id: Event::Unassignment.where(primary_user_id: user.id).select(:submitted_claim_id))
      .order(:created_at)
  }

  def editable?
    Assess::MakeDecisionForm::STATES.exclude?(state)
  end

  def display_state?
    Assess::SendBackForm::STATES.include?(state) || !editable?
  end
end
