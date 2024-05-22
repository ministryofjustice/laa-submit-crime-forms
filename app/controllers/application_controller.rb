class ApplicationController < LaaMultiStepForms::ApplicationController
  include Pagy::Backend
  include ApplicationHelper
  include CookieConcern
  helper_method :pagy

  before_action :set_default_cookies
  before_action :can_access_service

  private

  def can_access_service
    return unless current_provider
    return if Providers::Gatekeeper.new(current_provider).provider_enrolled?(service:)

    Rails.logger.warn "Not enrolled provider access attempt, UID: #{current_provider.id}, " \
                      "accounts: #{current_provider.office_codes}, service: #{service}"

    redirect_to root_path
  end

  def service
    Providers::Gatekeeper::ANY_SERVICE
  end
end
