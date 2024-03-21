module AllowedValueHelper
  def allowed_value(formatted_requested_cost, adjusted_cost, allowance_type)
    case allowance_type
    when :original
      formatted_requested_cost
    when :na
      I18n.t('prior_authority.generic.not_applicable')
    else
      NumberTo.pounds(adjusted_cost)
    end
  end
end
