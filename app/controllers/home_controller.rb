class HomeController < ApplicationController
  skip_before_action :authenticate_provider!, only: :dev_login
  before_action :destroy_session, only: :index

  layout 'submit_a_crime_form'

  def index
    @notification_banner = NotificationBanner.active_banner
  end

  def dev_login; end

  private

  # Part of the SSO flow
  #
  # If the conditions are met, we are trying to trigger a new SSO
  # session as the user has logged in as another user in the landing
  # page.
  def destroy_session
    return unless provider_signed_in?
    return if params[:login_hint].blank?
    return unless URI::MailTo::EMAIL_REGEXP.match?(params[:login_hint])
    return if current_provider.email == params[:login_hint]

    user = current_provider
    sign_out(user)
    cookies[:login_hint] = params[:login_hint]
    redirect_to root_path
  end
end
