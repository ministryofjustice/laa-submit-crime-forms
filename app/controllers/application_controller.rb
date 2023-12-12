class ApplicationController < LaaMultiStepForms::ApplicationController
  include Pagy::Backend
  include ApplicationHelper
  include CookieConcern

  before_action :set_default_cookies
end
