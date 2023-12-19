module LaaMultiStepForms
  class ApplicationController < ActionController::Base
    include ErrorHandling
    helper StepsHelper
    include ApplicationHelper

    prepend_before_action :authenticate_user!
  end
end
