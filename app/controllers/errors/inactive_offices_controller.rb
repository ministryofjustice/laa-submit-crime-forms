module Errors
  class InactiveOfficesController < ApplicationController
    skip_before_action :authenticate_provider!
  end
end
