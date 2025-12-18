class ApplicationController < LaaMultiStepForms::ApplicationController
  include Pagy::Backend
  include ApplicationHelper
  include CookieConcern

  helper_method :pagy, :pagy_array

  before_action :check_maintenance_mode
  before_action :set_default_cookies

  private

  def check_maintenance_mode
    return if Rails.env.test?
    return unless bank_holidays? || !business_hours? || ENV.fetch('MAINTENANCE_MODE', 'false') == 'true'

    render file: 'public/maintenance.html', layout: false
  end

  def bank_holidays?
    special_ranges = [
      (Date.new(2025, 12, 25)..Date.new(2025, 12, 26)),
      Date.new(2026, 1, 1)
    ]

    date = Time.current.to_date
    special_ranges.any? do |range_or_date|
      range_or_date.is_a?(Range) ? range_or_date.cover?(date) : range_or_date == date
    end
  end

  def business_hours?
    uk_time = Time.current.in_time_zone('Europe/London')
    start_time = uk_time.beginning_of_day + 7.hours
    end_time = uk_time.beginning_of_day + 21.hours + 30.minutes
    uk_time >= start_time && uk_time < end_time
  end
end
