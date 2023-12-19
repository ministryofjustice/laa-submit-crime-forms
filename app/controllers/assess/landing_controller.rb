# frozen_string_literal: true

module Assess
  class LandingController < Assess::ApplicationController
    skip_before_action :authenticate_user!
    skip_before_action :authorize_user!
    skip_before_action :set_security_headers
    before_action :redirect_if_authenticated

    def redirect_if_authenticated
      return unless user_signed_in?

      redirect_to assess_claims_path
    end
  end
end
