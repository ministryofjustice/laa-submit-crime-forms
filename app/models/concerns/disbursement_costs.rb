module DisbursementCosts
  extend ActiveSupport::Concern

  included do
    if self == ::Disbursement
      alias_method :application, :claim
      define_method(:record) { self }
    end
  end

  def other_disbursement_type?
    record.disbursement_type == DisbursementTypes::OTHER.to_s
  end

  def total_cost_pre_vat
    calculation[:claimed_total_exc_vat]
  end

  def allowed_total_cost_pre_vat
    calculation[:assessed_total_exc_vat]
  end

  def vat
    calculation[:claimed_vat]
  end

  def allowed_vat
    calculation[:assessed_vat]
  end

  def total_cost
    calculation[:claimed_total_inc_vat]
  end

  def allowed_total_cost
    calculation[:assessed_total_inc_vat]
  end

  def assessed_miles
    record.allowed_miles || miles
  end

  def assessed_total_cost_without_vat
    record.allowed_total_cost_without_vat || total_cost_without_vat
  end

  def assessed_apply_vat
    record.allowed_apply_vat || apply_vat
  end

  def data_for_calculation
    {
      disbursement_type: record.disbursement_type,
      claimed_cost: total_cost_without_vat,
      claimed_miles: miles,
      claimed_apply_vat: apply_vat?,
      assessed_cost: assessed_total_cost_without_vat,
      assessed_miles: assessed_miles,
      assessed_apply_vat: assessed_apply_vat?,
    }
  end

  private

  # TODO: consider refactoring
  # we use apply_vat in different ways in the form (boolean) v model (string) which
  # complicates theis feature
  def apply_vat?
    apply_vat.in?([true, 'true'])
  end

  def assessed_apply_vat?
    assessed_apply_vat.in?([true, 'true'])
  end

  def calculation
    @calculation ||= LaaCrimeFormsCommon::Pricing::Nsm.calculate_disbursement(
      application.data_for_calculation,
      data_for_calculation
    )
  rescue StandardError
    # This may be because we have simply not yet entered enough data
    # to calculate this correctly
    {}
  end
end
