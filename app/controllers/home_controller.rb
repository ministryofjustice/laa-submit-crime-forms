class HomeController < ApplicationController
  skip_before_action :authenticate_provider!, only: :dev_login
  layout 'submit_a_crime_form'

  def index
    @notification_banner = NotificationBanner.active_banner
  end

  def dev_login
    @test_data_providers = Provider.where('email LIKE ?', 'test-data-provider-%@example.com').order(:email)
  end
end
