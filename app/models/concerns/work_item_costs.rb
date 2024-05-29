module WorkItemCosts
  extend ActiveSupport::Concern

  included do
    alias_method :application, :claim if self == ::WorkItem
  end

  def allow_uplift?
    application.reasons_for_claim.include?(ReasonForClaim::ENHANCED_RATES_CLAIMED.to_s)
  end

  def apply_uplift
    allow_uplift? &&
      (@apply_uplift.nil? ? uplift.to_f.positive? : @apply_uplift == 'true')
  end

  def total_cost
    return if time_spent.nil? || time_spent.is_a?(Hash) || pricing[work_type].nil?

    # We need to use a Rational because some numbers divided by 60 cannot be accurately represented as a decimal,
    # and when summing up multiple work items with sub-penny precision, those small inaccuracies can lead to
    # a larger inaccuracy when the total is eventually rounded to 2 decimal places.
    Rational(apply_uplift!(time_spent.to_d) * pricing[work_type], 60)
  end

  def allowed_total_cost
    return total_cost if allowed_time_spent.nil? && allowed_uplift.nil?

    # We need to use a Rational because some numbers divided by 60 cannot be accurately represented as a decimal,
    # and when summing up multiple work items with sub-penny precision, those small inaccuracies can lead to
    # a larger inaccuracy when the total is eventually rounded to 2 decimal places.
    Rational(apply_uplift!((allowed_time_spent || time_spent).to_d, allowed_uplift || uplift) * pricing[work_type], 60)
  end

  def apply_uplift!(val, multipler = uplift)
    (BigDecimal('1') + (apply_uplift ? (multipler.to_d / 100) : 0)) * val
  end

  def pricing
    @pricing ||= Pricing.for(application)
  end

  private

  def total_without_uplift
    return if time_spent.nil? || time_spent.is_a?(Hash) || pricing[work_type].nil?

    time_spent.to_d / 60 * pricing[work_type]
  end
end
