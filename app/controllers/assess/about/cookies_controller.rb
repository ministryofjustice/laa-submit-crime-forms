# frozen_string_literal: true

module Assess
  module About
    class CookiesController < Assess::ApplicationController
      skip_before_action :authenticate_user!
      skip_before_action :authorize_user!

      def index
        usage_cookie = cookies[:analytics_cookies_set]
        @cookie = Cookie.new(analytics: usage_cookie)
        store_previous_page_url
      end

      def create
        @cookie = Cookie.new(cookie_params[:cookie])
        if @cookie.valid?
          set_cookies
          set_flash_notification
          redirect_to assess_about_cookies_path
        else
          render :index
        end
      end

      def update_cookies
        cookie_params = params.permit(:cookies_preference, :hide_banner)

        render(partial: 'layouts/assess/cookie_banner/hide') && return if params['hide_banner'] == 'true'

        update_analytics_cookies(ActiveModel::Type::Boolean.new.cast(cookie_params[:cookies_preference]))

        render(partial: 'layouts/assess/cookie_banner/success',
               locals: { analytics_cookies_accepted: cookies[:analytics_cookies_set] })
      end

      private

      def set_cookies
        set_cookie(:analytics_cookies_set, value: @cookie.analytics)
        set_cookie(:cookies_preferences_set, value: true)
      end

      def set_flash_notification
        previous_page_path = session.delete(:return_to)
        flash[:success] = t('assess.cookie_settings.notification_banner.preferences_set_html', href: previous_page_path)
      end

      def store_previous_page_url
        session[:return_to] = request.referer
      end

      def cookie_params
        params.permit(cookie: :analytics)
      end
    end
  end
end
