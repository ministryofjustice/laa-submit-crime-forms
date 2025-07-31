class ApplicationController < LaaMultiStepForms::ApplicationController
  include Pagy::Backend
  include ApplicationHelper
  include CookieConcern

  helper_method :pagy, :pagy_array

  before_action :check_maintenance_mode
  before_action :set_default_cookies

  private

  def check_maintenance_mode
    return unless ENV.fetch('MAINTENANCE_MODE', 'false') == 'true'

    render file: 'public/maintenance.html', layout: false
  end
end
