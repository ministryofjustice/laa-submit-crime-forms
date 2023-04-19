module LaaMultiStepForms
  class ApplicationController < ActionController::Base
    include ErrorHandling
    helper StepsHelper

    prepend_before_action :authenticate_provider!

    def current_application
      raise 'implement this action, in subclasses'
    end
    helper_method :current_application
  end
end
