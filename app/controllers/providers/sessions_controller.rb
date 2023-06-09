module Providers
  class SessionsController < Devise::SessionsController
    private

    def after_sign_out_path_for(*)
      root_path
    end
  end
end
