module CostSummary
  class WorkItems < Base
    attr_reader :work_item_forms, :claim

    def initialize(work_items, claim)
      @claim = claim
      @work_item_forms = work_items
                            .map { |work_item| Steps::WorkItemForm.build(work_item, application: claim) }
    end

    def rows
      forms = work_item_forms.group_by(&:work_type)
      work_types = WorkTypes.values.filter { |work_type| work_type.display?(claim) }

      work_types.map do |work_type|
        total_cost = forms[work_type]&.sum(&:total_cost).to_f || 0.0
        {
          key: { text: t(work_type.to_s) },
          value: { text: f(total_cost) },
        }
      end
    end

    def total_cost
      @total_cost ||= work_item_forms.sum(&:total_cost)
    end

    def title
      t("work_items", total: f(total_cost))
    end
  end
end