module Providers
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token
    skip_before_action :can_access_service
    before_action :check_provider_is_enrolled, only: [:saml]

    def saml
      if Provider.active_offices?(auth_hash)
        provider = Provider.from_omniauth(auth_hash)

        sign_in_and_redirect(
          provider, event: :authentication
        )
      else
        redirect_to inactive_offices_path
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
      gatekeeper = Providers::Gatekeeper.new(auth_hash.info)
      Rails.logger.warn auth_hash.info.office_codes
      return if gatekeeper.provider_enrolled?

      Rails.logger.warn "Not enrolled provider access attempt, UID: #{auth_hash.uid}, " \
                        "accounts: #{auth_hash.info.office_codes}, "

      redirect_to laa_msf.not_enrolled_errors_path
    end
  end
end
