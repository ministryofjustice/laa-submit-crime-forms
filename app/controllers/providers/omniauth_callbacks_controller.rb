module Providers
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token

    def entra_id
      active_office_codes = ActiveOfficeCodeService.call(office_codes)

      if active_office_codes.any?
        provider = Provider.from_omniauth(auth_data, office_codes)

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
      cookies.delete(:login_hint)
      root_path
    end

    # Handle Entra errors as part of SSO flow
    #
    # If we get an error that requires some input, this (most likely)
    # means that the user is logged in with multiple accounts
    #
    # In that case, try silent auth again without the login_hint, and
    # if that still fails then we go to the "login" page
    def after_omniauth_failure_path_for(*)
      error = params[:error] || params[:message]

      case error
      when 'login_required', 'interaction_required'
        if session[:tried_silent_auth]
          session.delete(:tried_silent_auth)
          unauthorized_errors_path
        else
          session[:tried_silent_auth] = true
          providers_retry_auth_path
        end
      else
        unauthorized_errors_path
      end
    end

    def auth_data
      request.env['omniauth.auth']
    end

    def office_codes
      auth_data.info.office_codes
    end
  end
end
