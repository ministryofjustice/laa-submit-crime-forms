module Assess
  class ClaimsController < Assess::ApplicationController
    def index
      claims = SubmittedClaim.pending_decision
      claims = claims.map { |claim| BaseViewModel.build(:all_claims, claim) }
      @pagy, @claims = pagy_array(claims)
    end

    def new
      claim = SubmittedClaim.unassigned_claims(current_user).order(created_at: :desc).first

      if claim
        SubmittedClaim.transaction do
          claim.assignments.create!(user: current_user)
          Event::Assignment.build(claim:, current_user:)
        end

        redirect_to assess_claim_claim_details_path(claim)
      else
        redirect_to assess_your_claims_path, flash: { notice: t('.no_pending_claims') }
      end
    end
  end
end
