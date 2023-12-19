module ApplicationHelper
  # moved here to allow view specs to work
  def current_application
    @current_application ||= Claim.for(current_user).find_by(id: params[:id])
  end

  def current_office_code
    @current_office_code ||= current_user&.selected_office_code
  end

  def maat_required?(form)
    form.application.claim_type != ClaimType::BREACH_OF_INJUNCTION.to_s
  end

  def multiline_text(string)
    return unless string

    ApplicationController.helpers.sanitize(string.gsub("\n", '<br>'), tags: %w[br])
  end
end
