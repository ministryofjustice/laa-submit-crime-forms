class HomeController < ApplicationController
  skip_before_action :authenticate_provider!, only: :dev_login
  layout 'submit_a_crime_form'

  def index
    @notification_banner = NotificationBanner.active_banner
  end

  def dev_login; end

  def uncovered
    render plain: 'I am not covered'
  end
end
