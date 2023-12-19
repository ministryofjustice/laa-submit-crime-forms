module Assess
  class UnassignmentForm
    include ActiveModel::Model
    include ActiveModel::Attributes
    include ActiveRecord::AttributeAssignment

    attribute :comment
    attribute :current_user
    attribute :claim

    validates :claim, presence: true
    validates :comment, presence: true

    def unassignment_user
      user == current_user ? 'assigned' : 'other'
    end

    def user
      @user ||= assignment.user
    end

    def save
      return false unless valid?

      if assignment
        SubmittedClaim.transaction do
          Event::Unassignment.build(claim:, user:, current_user:, comment:)

          assignment.delete
        end
      end

      true
    end

    private

    def assignment
      @assignment ||= claim.assignments.first
    end
  end
end
