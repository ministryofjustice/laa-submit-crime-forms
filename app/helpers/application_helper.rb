module ApplicationHelper
  # moved here to allow view specs to work
  def current_application
    @current_application ||= Claim.find_by(id: params[:id])
  end

  def current_office_code
    @current_office_code ||= current_provider&.selected_office_code || current_provider&.office_codes&.first
  end

  def maat_required?(form)
    form.application.claim_type != ClaimType::BREACH_OF_INJUNCTION.to_s
  end

  def capitalize_sym(obj)
    if obj.is_a?(TrueClass)
      YesNoAnswer::YES.to_s.capitalize
    elsif obj.is_a?(FalseClass)
      YesNoAnswer::NO.to_s.capitalize
    else
      obj&.value.to_s.capitalize
    end
  end
end
