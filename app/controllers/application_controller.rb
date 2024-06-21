class ApplicationController < LaaMultiStepForms::ApplicationController
  include Pagy::Backend
  include ApplicationHelper
  include CookieConcern
  helper_method :pagy

  before_action :check_maintenance_mode
  before_action :set_default_cookies
  before_action :can_access_service

  private

  def can_access_service
    return unless current_provider
    return if Providers::Gatekeeper.new(current_provider).provider_enrolled_and_active?(service:)

    Rails.logger.warn "Not enrolled provider access attempt, UID: #{current_provider.id}, " \
                      "accounts: #{current_provider.office_codes}, service: #{service}"

    if service == Providers::Gatekeeper::ANY_SERVICE
      redirect_to errors_inactive_offices_path
    else
      redirect_to root_path
    end
  end

  def service
    Providers::Gatekeeper::ANY_SERVICE
  end

  def check_maintenance_mode
    return unless FeatureFlags.maintenance_mode.enabled?

    render file: 'public/maintenance.html', layout: false
  end
end
