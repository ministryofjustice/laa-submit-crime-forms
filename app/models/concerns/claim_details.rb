module ClaimDetails
  extend ActiveSupport::Concern

  included do
    include LettersAndCallsCosts
    include StageReachedCalculatable
  end

  def show_adjusted?
    return false unless granted? || part_grant?

    totals[:totals][:claimed_total_inc_vat] != totals[:totals][:assessed_total_inc_vat]
  end

  def totals
    @totals ||= LaaCrimeFormsCommon::Pricing::Nsm.totals(full_data_for_calculation)
  end

  def rates
    @rates ||= LaaCrimeFormsCommon::Pricing::Nsm.rates(data_for_calculation)
  end

  def full_data_for_calculation
    data_for_calculation.merge(
      work_items: work_items_for_calculation,
      disbursements: disbursements_for_calculation,
      letters_and_calls: letters_and_calls_for_calculation,
    )
  end

  def data_for_calculation
    {
      claim_type: claim_type,
      rep_order_date: rep_order_date,
      cntp_date: cntp_date,
      claimed_youth_court_fee_included: include_youth_court_fee || false,
      assessed_youth_court_fee_included: allowed_youth_court_fee || false,
      youth_court: youth_court == 'yes',
      plea_category: plea_category,
      vat_registered: firm_office.vat_registered == 'yes',
      work_items: [],
      letters_and_calls: [],
      disbursements: []
    }
  end

  def work_items_for_calculation
    work_items.select(&:complete?).map(&:data_for_calculation)
  end

  def disbursements_for_calculation
    disbursements.select(&:complete?).map(&:data_for_calculation)
  end
end
