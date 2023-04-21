module ApplicationHelper
  # moved here to allow view specs to work
  def current_application
    @current_application ||= Claim.find_by(id: params[:id])
  end

  def current_office_code
    @current_office_code ||= current_provider&.selected_office_code || current_provider&.office_codes&.first
  end

  def service_name
    t('service.name')
  end

  def title(page_title)
    content_for(
      :page_title, [page_title.presence, service_name, 'GOV.UK'].compact.join(' - ')
    )
  end

  # In local/test we raise an exception, so we are aware a title has not been set
  def fallback_title
    exception = StandardError.new("page title missing: #{controller_name}##{action_name}")
    raise exception if Rails.application.config.consider_all_requests_local

    title ''
  end
end
