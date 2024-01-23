module Nsm
  module CostSummary
    class WorkItems < Base
      TRANSLATION_KEY = self
      attr_reader :work_item_forms, :claim

      def initialize(work_items, claim)
        @claim = claim
        @work_item_forms = work_items
                           .map { |work_item| Nsm::Steps::WorkItemForm.build(work_item, application: claim) }
      end

      def rows
        forms = work_item_forms.group_by(&:work_type)
        work_types = WorkTypes.values.filter { |work_type| work_type.display?(claim) }

        work_types.map do |work_type|
          total_cost = forms[work_type]&.sum(&:total_cost)
          {
            key: { text: translate(work_type.to_s), classes: 'govuk-summary-list__value-width-50' },
            value: { text: NumberTo.pounds(total_cost || 0) },
          }
        end
      end

      def footer_vat_row
        return [] if total_cost_inc_vat.zero?

        [
          {
            key: { text: translate('.footer.total_inc_vat'), classes: 'govuk-summary-list__value-width-50' },
            value: { text: NumberTo.pounds(total_cost_inc_vat), classes: 'govuk-summary-list__value-bold' },
          }
        ]
      end

      def total_cost
        @total_cost ||= work_item_forms.sum(&:total_cost)
      end

      def total_cost_inc_vat
        @total_cost_inc_vat ||= calculate_vat
      end

      def calculate_vat
        return 0 if @claim.firm_office.vat_registered == YesNoAnswer::NO.to_s

        (total_cost * vat_rate) + total_cost
      end

      def title
        translate('work_items', total: NumberTo.pounds(vat_registered ? total_cost_inc_vat : total_cost || 0))
      end
    end
  end
end
