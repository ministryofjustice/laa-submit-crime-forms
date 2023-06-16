class HomeController < ApplicationController
  before_action :capture_test_error
  skip_before_action :authenticate_provider!
  
  #DELETE AFTER TESTING
  def capture_test_error
    begin
      1 / 0
    rescue ZeroDivisionError => exception
      Sentry.capture_exception(exception)
    end
    
    Sentry.capture_message("test message") 
end
