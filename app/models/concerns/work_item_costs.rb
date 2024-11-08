module WorkItemCosts
  extend ActiveSupport::Concern

  included do
    if self == ::WorkItem
      alias_method :application, :claim
      define_method(:record) { self }
    end
  end

  def allow_uplift?
    application.reasons_for_claim.include?(ReasonForClaim::ENHANCED_RATES_CLAIMED.to_s)
  end

  def apply_uplift
    allow_uplift? &&
      (@apply_uplift.nil? ? uplift.to_f.positive? : @apply_uplift == 'true')
  end

  def total_cost
    calculation[:claimed_total_exc_vat]
  end

  def allowed_total_cost
    calculation[:assessed_total_exc_vat]
  end

  delegate :rates, to: :application

  def assessed_work_type
    record.allowed_work_type.presence || work_type
  end

  def assessed_time_spent
    record.allowed_time_spent || time_spent
  end

  def assessed_uplift
    record.allowed_uplift || uplift
  end

  def data_for_calculation
    {
      claimed_time_spent_in_minutes: time_spent.present? && time_spent.to_i,
      claimed_work_type: work_type.to_s,
      claimed_uplift_percentage: apply_uplift ? uplift : 0,
      assessed_time_spent_in_minutes: assessed_time_spent.present? && assessed_time_spent.to_i,
      assessed_work_type: assessed_work_type.to_s,
      assessed_uplift_percentage: apply_uplift ? assessed_uplift : 0,
    }
  end

  private

  def total_without_uplift
    calculation[:claimed_subtotal_without_uplift]
  end

  def calculation
    @calculation ||= LaaCrimeFormsCommon::Pricing::Nsm.calculate_work_item(
      application.data_for_calculation,
      data_for_calculation
    )
  rescue StandardError
    # If we don't have enough details yet to do the calculation, this will error out
    {}
  end
end
