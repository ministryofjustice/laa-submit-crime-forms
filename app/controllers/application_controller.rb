class ApplicationController < LaaMultiStepForms::ApplicationController
  include Pagy::Backend
  include ApplicationHelper
  include CookieConcern

  before_action :set_default_cookies
  before_action :can_access_service

  def cas_access_service
    return if Provider::Gatekeeper.provider_enrolled?(service:)

    Rails.logger.warn "Not enrolled provider access attempt, UID: #{auth_hash.uid}, " \
                      "accounts: #{auth_hash.info.office_codes}, service: #{service}"

    redirect_to laa_msf.not_enrolled_errors_path, flash: { notice: 'You do not have access to that srevice'}

  end

  def service
    Provider::Gatekeeper::ANY
  end
end
