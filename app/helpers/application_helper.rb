module ApplicationHelper
  # moved here to allow view specs to work
  def current_application
    @current_application ||= Claim.find_by(id: params[:id])
  end

  def current_office_code
    @current_office_code ||= current_provider&.selected_office_code || current_provider&.office_codes&.first
  end

  def maat_required?(form)
    form.application.claim_type != ClaimType::NON_STANDARD_MAGISTRATE
  end
end
