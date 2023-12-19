class ApplicationController < LaaMultiStepForms::ApplicationController
  include Pagy::Backend
  include ApplicationHelper
  include CookieConcern

  layout 'application'

  before_action :set_default_cookies
  before_action :authorize_user!

  def authorize_user!
    return if current_user.role == User::PROVIDER
    return if allowed_office_codes.intersect?(current_user.office_codes)

    redirect_to root_path
  end

  private

  def allowed_office_codes
    Rails.configuration.x.gatekeeper.office_codes
  end
end
