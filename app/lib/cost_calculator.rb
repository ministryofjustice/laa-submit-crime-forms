module CostCalculator
  class << self
    def cost(type, object, vat)
      case type
      when :travel_and_waiting_total
        travel_and_waiting_total(vat, object)
      end
    end

    private

    def travel_and_waiting_total(vat, object)
      pricing = Pricing.for(object)
      vat_rate = pricing.vat
      total_without_vat = work_items_total(work_items(object), pricing)
      total = vat ? total_without_vat * (1 + vat_rate) : total_without_vat
      total.round(2)
    end

    def work_items_total(items, pricing)
      items.sum { |i| work_item_total(i, pricing) }
    end

    def work_item_total(item, pricing)
      (item.time_spent / 60.to_f) * pricing[item.work_type] * (1 + (item[:uplift] / 100.to_f))
    end

    def work_items(object)
      WorkItem.where(claim_id: object[:id], work_type: %w[travel waiting])
    end
  end
end
