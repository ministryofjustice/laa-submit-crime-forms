class HomeController < ApplicationController
  before_action :capture_test_error
  skip_before_action :authenticate_provider!

  # DELETE AFTER TESTING
  def capture_test_error
    1 / 0
  rescue ZeroDivisionError => e
    Sentry.capture_exception(e)
  end
end
