# TODO: use base controller from library??
class ApplicationController < LaaMultiStepForms::ApplicationController
  def current_application
    @current_application ||= Claim.find_by(usn: params[:id])
  end

  def current_office_code
    @current_office_code ||= current_provider&.selected_office_code || current_provider&.office_codes&.first
  end
  helper_method :current_office_code
end
