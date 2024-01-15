module PriorAuthority
  module Steps
    class BaseController < ::Steps::BaseStepController
      include ApplicationHelper
      include CookieConcern

      layout 'prior_authority'

      before_action :set_default_cookies
      before_action :authenticate_provider!
    end
  end
end
