module PriorAuthority
  class BaseController < ActionController::Base
    include CookieConcern
    before_action :set_default_cookies
    before_action :authenticate_provider!
    layout 'prior_authority'
  end
end
