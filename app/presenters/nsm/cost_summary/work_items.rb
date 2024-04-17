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
        work_types = WorkTypes.values.filter { |work_type| work_type.display?(claim) }

        work_types.map do |work_type|
          [
            { text: translate(work_type.to_s), classes: 'govuk-table__header' },
            { text: ApplicationController.helpers.format_period(time_spent_for(work_type)) },
            { text: NumberTo.pounds(total_cost_for(work_type) || 0), classes: 'govuk-table__cell--numeric' },
          ]
        end
      end

      def total_cost_for(work_type)
        forms[work_type]&.sum(&:total_cost)
      end

      def time_spent_for(work_type)
        forms[work_type]&.sum(&:time_spent) || 0
      end

      def forms
        @forms ||= work_item_forms.group_by(&:work_type)
      end

      def total_cost
        @total_cost ||= work_item_forms.sum(&:total_cost)
      end

      def total_cost_inc_vat
        @total_cost_inc_vat ||= calculate_vat
      end

      def calculate_vat
        return 0 unless vat_registered

        (total_cost * vat_rate) + total_cost
      end

      def title
        translate('work_items')
      end
    end
  end
end
