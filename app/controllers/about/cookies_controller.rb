# frozen_string_literal: true

module About
  class CookiesController < ApplicationController
    skip_before_action :authenticate_provider!

    def index
      usage_cookie = cookies[:analytics_cookies_set]
      @cookie = Cookie.new(analytics: usage_cookie)
      store_previous_page_url
    end

    def store_previous_page_url
      session[:return_to] = request.referer
    end
  end
end
