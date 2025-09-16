class ApplicationController < LaaMultiStepForms::ApplicationController
  include Pagy::Backend
  include ApplicationHelper
  include CookieConcern

  helper_method :pagy, :pagy_array

  before_action :check_maintenance_mode
  before_action :set_default_cookies

  private

  def check_maintenance_mode
    return unless !business_hours? || ENV.fetch('MAINTENANCE_MODE', 'false') == 'true'

    render file: 'public/maintenance.html', layout: false
  end

  def business_hours?
    uk_time = Time.current.in_time_zone('Europe/London')
    (7..18).cover?(uk_time.hour) && uk_time.on_weekday?
  end
end
