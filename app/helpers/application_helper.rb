module ApplicationHelper
  # moved here to allow view specs to work
  def current_application
    @current_application ||=
      Claim.for(current_provider).find_by(id: params[:id]) ||
      PriorAuthorityApplication.for(current_provider).find_by(id: params[:application_id])
  end

  def current_office_code
    @current_office_code ||= current_provider&.selected_office_code
  end

  def maat_required?(form)
    form.application.claim_type != ClaimType::BREACH_OF_INJUNCTION.to_s
  end

  def multiline_text(string)
    ApplicationController.helpers.sanitize(string.gsub("\n", '<br>'), tags: %w[br])
  end

  def relevant_prior_authority_list_anchor(prior_authority_application)
    case prior_authority_application.status
    when 'submitted'
      :submitted
    when 'draft'
      :draft
    else
      :assessed
    end
  end
end
