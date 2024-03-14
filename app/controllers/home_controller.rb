class HomeController < ApplicationController
  skip_before_action :authenticate_provider!, only: :dev_login
  skip_before_action :can_access_service, only: :dev_login
  layout 'submit_a_crime_form'

  def index
    @gatekeeper = Providers::Gatekeeper.new(current_provider)
  end

  def dev_login; end
end
