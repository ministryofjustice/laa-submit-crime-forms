module ApplicationHelper
  # moved here to allow view specs to work
  def current_application
    @current_application ||= Claim.for(current_provider).find_by(id: params[:id])
  end

  def current_prior_auth_application ||= PriorAuthority.for(current_provider).find_by(id: params[:id])

  def current_office_code
    @current_office_code ||= current_provider&.selected_office_code
  end

  def maat_required?(form)
    form.application.claim_type != ClaimType::BREACH_OF_INJUNCTION.to_s
  end

  def multiline_text(string)
    ApplicationController.helpers.sanitize(string.gsub("\n", '<br>'), tags: %w[br])
  end
end
