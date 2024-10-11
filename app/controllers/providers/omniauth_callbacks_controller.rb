module Providers
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token

    def saml
      active_office_codes = ActiveOfficeCodeService.call(auth_hash.info.office_codes)

      if active_office_codes.any?
        provider = Provider.from_omniauth(auth_hash)

        sign_in_and_redirect(
          provider, event: :authentication
        )
      else
        redirect_to errors_inactive_offices_path
      end
    end

    def failure
      redirect_to after_omniauth_failure_path_for, flash: { notice: t('errors.generic_login_failed') }
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
  end
end
