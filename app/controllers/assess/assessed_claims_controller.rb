module Assess
  class AssessedClaimsController < Assess::ApplicationController
    def index
      claims = SubmittedClaim.decision_made
      claims = claims.map { |claim| BaseViewModel.build(:assessed_claims, claim) }
      @pagy, @claims = pagy_array(claims)
    end
  end
end
