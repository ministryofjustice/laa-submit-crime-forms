class HomeController < ApplicationController
  before_action :capture_test_error
  skip_before_action :authenticate_provider!
end
