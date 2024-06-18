module Providers
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token
    skip_before_action :can_access_service
    before_action :check_provider_is_enrolled, only: [:saml]

    def saml
      active_office_codes = gatekeeper.active_office_codes

      if active_office_codes.any?
        provider = Provider.from_omniauth(auth_hash, active_office_codes)

        sign_in_and_redirect(
          provider, event: :authentication
        )
      else
        redirect_to errors_inactive_offices_path
      end
    end

    private

    def after_sign_in_path_for(*)
      root_path
    end

    def after_omniauth_failure_path_for(*)
      new_provider_session_path
    end

    def auth_hash
      request.env['omniauth.auth']
    end

    def check_provider_is_enrolled
      return if gatekeeper.provider_enrolled?

      Rails.logger.warn "Not enrolled provider access attempt, UID: #{auth_hash.uid}, " \
                        "accounts: #{auth_hash.info.office_codes}, "

      redirect_to laa_msf.not_enrolled_errors_path
    end

    def gatekeeper
      @gatekeeper ||= Providers::Gatekeeper.new(auth_hash.info)
    end
  end
end
