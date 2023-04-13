class ApplicationController < ActionController::Base
  prepend_before_action :authenticate_provider!

  def current_office_code
    @current_office_code ||= current_provider&.selected_office_code
  end
  helper_method :current_office_code
end
