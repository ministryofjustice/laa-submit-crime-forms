class HomeController < ApplicationController
  skip_before_action :authenticate_user!, :authorize_user!
end
