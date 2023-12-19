module Users
  class SessionsController < Devise::SessionsController
    skip_before_action :authorize_user!

    private

    def after_sign_out_path_for(*)
      root_path
    end
  end
end
