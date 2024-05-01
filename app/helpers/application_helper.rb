module ApplicationHelper
  # moved here to allow view specs to work
  def current_application
    @current_application ||=
      Claim.for(current_provider).find_by(id: params[:id]) ||
      PriorAuthorityApplication.for(current_provider).find_by(id: params[:application_id] || params[:id])
  end

  def maat_required?(form)
    form.application.claim_type != ClaimType::BREACH_OF_INJUNCTION.to_s
  end

  def multiline_text(string)
    ApplicationController.helpers.sanitize(string.gsub("\n", '<br>'), tags: %w[br])
  end

  def further_information_needed
    if current_application.further_informations.empty?
      false
    else
      last_further_info = current_application.further_informations.order(:created_at).last.created_at
      current_application.sent_back? && (last_further_info >= current_application.app_store_updated_at)
    end
  end

  def relevant_prior_authority_list_anchor(prior_authority_application)
    case prior_authority_application.status
    when 'submitted'
      :submitted
    when 'draft'
      :draft
    else
      :reviewed
    end
  end
end
