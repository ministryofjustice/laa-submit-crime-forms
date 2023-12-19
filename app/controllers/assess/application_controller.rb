module Assess
  class ApplicationController < ActionController::Base
    include Pagy::Backend
    include ApplicationHelper
    include CookieConcern
    default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

    before_action :authenticate_user!
    before_action :authorize_user!
    before_action :set_security_headers
    before_action :set_default_cookies

    layout 'assess_application'

    private

    def set_security_headers
      response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
      response.headers['Pragma'] = 'no-cache'
    end

    def authorize_user!
      return if [User::CASEWORKER, User::SUPERVISOR].include?(current_user.role)

      redirect_to root_path
    end

    def after_sign_in_path_for(*)
      assess_claims_path
    end
  end
end
