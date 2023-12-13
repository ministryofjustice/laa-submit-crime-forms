# frozen_string_literal: true

class ClaimCalculator
  def initialize(claim:)
    @claim = claim
    @items = {
      work_items: CostSummary::WorkItems.new(claim.work_items, claim),
      letters_calls: CostSummary::LettersCalls.new(claim),
      disbursements: CostSummary::Disbursements.new(claim.disbursements.by_age, claim)
    }
  end

  def save_totals
    @claim.update!({ submitted_total: total.round(2), submitted_total_inc_vat: total_inc_vat.round(2) })
  end

  def total
    @items.values.filter_map(&:total_cost).sum
  end

  def total_inc_vat
    @items.values.filter_map(&:total_cost_inc_vat).sum
  end
end
