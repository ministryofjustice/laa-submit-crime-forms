module Providers
  class SessionsController < Devise::SessionsController
    skip_before_action :authenticate_provider!, only: [:silent_auth, :retry_auth]

    # These forms are needed because the provider authorize endpoint
    # needs to be POST'd and you can't redirect to a POST

    def silent_auth
      @login_hint = cookies[:login_hint]
      @prompt = nil
      render :auth_form
    end

    def retry_auth
      @login_hint = nil
      @prompt = 'select_account'
      render :auth_form
    end

    private

    def after_sign_out_path_for(*)
      unauthorized_errors_path
    end
  end
end
