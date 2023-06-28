module ErrorHandling
  extend ActiveSupport::Concern

  included do
    rescue_from Exception do |exception|
      case exception
      when Errors::InvalidSession, ActionController::InvalidAuthenticityToken
        redirect_to laa_msf.invalid_session_errors_path
      when Errors::ApplicationNotFound
        redirect_to laa_msf.application_not_found_errors_path
      # NOTE: Add more custom errors as they are needed, for instance:
      # when Errors::ApplicationSubmitted
      #   redirect_to application_submitted_errors_path
      else
        raise

        Rails.logger.error(exception)
        Sentry.capture_exception(exception) if ENV.fetch('SENTRY_DSN', nil).present?
        redirect_to laa_msf.unhandled_errors_path if Rails.application.config.consider_all_requests_local
      end
    end
  end

  private

  def check_application_presence
    raise Errors::ApplicationNotFound unless current_application
  end
end
