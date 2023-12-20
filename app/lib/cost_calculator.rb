module CostCalculator
  class << self
    def cost(type, object, vat)
      case type
      when :travel_and_waiting_total
        travel_and_waiting_total(vat, object)
      when :disbursement_total
        disbursement_total(vat, object)
      end
    end

    private

    def travel_and_waiting_total(vat, object)
      pricing = Pricing.for(object)
      work_items_total(work_items(object), pricing, vat)
    end

    def work_items_total(items, pricing, vat)
      items.sum { |i| work_item_total(i, pricing, vat) }.round(2)
    end

    def work_item_total(item, pricing, vat)
      rounded_cost = (item.time_spent.to_f / 60) * pricing[item.work_type] * (1 + (item[:uplift].to_f / 100)).round(2)
      return (rounded_cost * (1 + pricing.vat)).floor(2) if vat == true

      rounded_cost
    end

    def disbursements_total(vat, object)
      pricing = Pricing.for(object)
      if vat == true
        disbursments.sum { |i| (i.total_cost_without_vat * (1 + pricing.vat)).floor(2) }.round(2)
      else
        disbursments.sum(&:total_cost_without_vat).round(2)
      end
    end

    def work_items(object)
      WorkItem.where(claim_id: object[:id], work_type: %w[travel waiting])
    end

    def disbursements(object)
      Disbursments.where(claim_id: object[:id])
    end
  end
end
