# TODO: use base controller from library??
class ApplicationController < LaaMultiStepForms::ApplicationController
  include ApplicationHelper

  rescue_from Exception, with: :unexpected_exception_handler

  def unexpected_exception_handler(exception)
    Sentry.capture_exception(exception)
  end
end
