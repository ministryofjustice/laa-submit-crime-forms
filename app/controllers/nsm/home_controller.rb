module Nsm
  class HomeController < ApplicationController
    def start
      redirect_to Providers::OfficeRouter.call(current_provider)
    end
  end
end
