module Nsm
  class HomeController < ApplicationController
    layout 'nsm'

    def start
      redirect_to Providers::OfficeRouter.call(current_provider)
    end
  end
end
