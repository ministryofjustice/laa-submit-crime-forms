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
      total_without_vat = work_items_total(work_items(object), pricing)

      return total_without_vat unless vat

      total_with_vat = total_without_vat * (1 + pricing.vat)
      total_with_vat.floor(2)
    end

    def work_items_total(items, pricing)
      items.sum { |i| work_item_total(i, pricing) }.round(2)
    end

    def work_item_total(item, pricing)
      (item.time_spent.to_f / 60) * pricing[item.work_type] * (1 + (item[:uplift].to_f / 100)).round(2)
    end

    def work_items(object)
      WorkItem.where(claim_id: object[:id], work_type: %w[travel waiting])
    end
  end
end
