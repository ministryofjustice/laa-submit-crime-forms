module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    skip_before_action :verify_authenticity_token, :authorize_user!
    before_action :check_provider_is_enrolled, only: [:saml]

    def saml
      provider = User.from_omniauth(auth_hash)

      sign_in_and_redirect(
        provider, event: :authentication
      )
    end

    def azure_ad
      @user = UserAuthenticate.new(request.env['omniauth.auth']).authenticate
      if @user
        sign_in_and_redirect @user, event: :authentication
      else
        redirect_to assess_root_path, flash: { notice: I18n.t('devise.failure.user.forbidden')[0] }
      end
    end

    # :nocov:
    def failure
      redirect_to new_user_session_path, flash: { notice: I18n.t('devise.failure.user.forbidden')[0] }
    end

    private

    def after_sign_in_path_for(*)
      if current_user.role == User::PROVIDER
        Providers::OfficeRouter.call(current_user)
      else
        assess_root_path
      end
    end

    def after_omniauth_failure_path_for(*)
      new_user_session_path
    end

    def auth_hash
      request.env['omniauth.auth']
    end

    def check_provider_is_enrolled
      gatekeeper = Providers::Gatekeeper.new(auth_hash.info)
      return if gatekeeper.provider_enrolled?

      Rails.logger.warn "Not enrolled provider access attempt, UID: #{auth_hash.uid}, " \
                        "accounts: #{auth_hash.info.office_codes}, "

      redirect_to laa_msf.not_enrolled_errors_path
    end

    # Override the #passthru action. It is used when a GET request is made
    # to the user auth url. Ideally the GET route would not be added by Devise.
    # The fix for this is in Devise but awaiting release:
    # https://github.com/heartcombo/devise/pull/5508
    def passthru
      redirect_to unauthenticated_root_path
    end
    # :nocov:
  end
end
