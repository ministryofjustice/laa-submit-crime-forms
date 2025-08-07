module Providers
  class SessionsController < Devise::SessionsController
    skip_before_action :authenticate_provider!, only: [:retry_auth]

    # This form is needed because the provider authorize endpoint
    # needs to be POST'd and you can't redirect to a POST

    def retry_auth; end

    private

    def after_sign_out_path_for(*)
      root_path
    end
  end
end
