module DisbursementCosts
  extend ActiveSupport::Concern

  included do
    if self == ::Disbursement
      alias_method :application, :claim
      define_method(:record) { self }
    end
  end

  # we return 1 here when no pricing data exists to simplify the FE
  def multiplier
    pricing[record.disbursement_type] || BigDecimal('1')
  end

  def other_disbursement_type?
    record.disbursement_type == DisbursementTypes::OTHER.to_s
  end

  def total_cost_pre_vat
    @total_cost_pre_vat ||= if other_disbursement_type?
                              total_cost_without_vat
                            elsif miles
                              miles.to_d * multiplier
                            end
  end

  def auth_required?
    total_cost_pre_vat && total_cost_pre_vat >= 100
  end

  def vat_rate
    pricing[:vat]
  end

  def vat
    return nil unless total_cost_pre_vat

    apply_vat.in?([true, 'true']) ? (total_cost_pre_vat * vat_rate).round(2) : BigDecimal('0')
  end

  def total_cost
    @total_cost ||= if apply_vat && total_cost_pre_vat
                      total_cost_pre_vat + vat
                    else
                      total_cost_pre_vat
                    end
  end

  private

  def pricing
    @pricing ||= Pricing.for(application)
  end
end
