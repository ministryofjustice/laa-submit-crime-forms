module Errors
  class InactiveOfficesController < ApplicationController
    skip_before_action :authenticate_provider!
    skip_before_action :can_access_service
  end
end
