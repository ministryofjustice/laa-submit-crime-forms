class HomeController < ApplicationController
  skip_before_action :authenticate_provider!
end
