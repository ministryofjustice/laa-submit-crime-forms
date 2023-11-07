class ApplicationController < LaaMultiStepForms::ApplicationController
  include ApplicationHelper
  include CookieConcern

  before_action :set_default_cookies
end
