module Providers
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token

    def saml
      active_office_codes = ActiveOfficeCodeService.call(office_codes)

      if active_office_codes.any?
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

    def auth_data
      request.env['omniauth.auth']
    end

    def provider
      Provider.from_omniauth(auth_data)
    end

    def office_codes
      if FeatureFlags.omniauth_test_mode.enabled?
        auth_data.info.office_codes
      else
        @office_codes ||= provider.office_codes
      end
    end
  end
end
