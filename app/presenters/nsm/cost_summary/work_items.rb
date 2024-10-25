module Nsm
  module CostSummary
    class WorkItems < Base
      TRANSLATION_KEY = self
      attr_reader :work_items, :claim

      def initialize(work_items, claim)
        @claim = claim
        @work_items = work_items
      end

      ORDER = %w[travel waiting attendance_with_counsel attendance_without_counsel preparation advocacy].freeze

      def rows
        work_types = WorkTypes.values.sort_by { ORDER.index(_1.to_s) }.filter { |work_type| work_type.display?(claim) }

        work_types.map do |work_type|
          [
            { text: I18n.t("laa_crime_forms_common.nsm.work_type.#{work_type}"), classes: 'govuk-table__header' },
            { text: ApplicationController.helpers.format_period(time_spent_for(work_type), style: :minimal_html) },
            { text: NumberTo.pounds(total_cost_for(work_type)), classes: 'govuk-table__cell--numeric' },
          ]
        end
      end

      def total_cost_for(work_type)
        claim.totals[:work_types][work_type.to_sym][:claimed_total_exc_vat]
      end

      def time_spent_for(work_type)
        IntegerTimePeriod.new(claim.totals[:work_types][work_type.to_sym][:claimed_time_spent_in_minutes].to_i)
      end

      def total_cost
        claim.totals[:work_types][:total][:claimed_total_exc_vat]
      end

      def total_cost_inc_vat
        claim.totals[:work_types][:total][:claimed_total_inc_vat]
      end

      def title
        translate('work_items')
      end

      def header_row
        [
          { text: tag.span(translate('.header.item'), class: 'govuk-visually-hidden') },
          { text: translate('.header.time') },
          { text: translate('.header.net_cost'), classes: 'govuk-table__header--numeric' },
        ]
      end

      def work_item_summary_header_row
        [
          { text: tag.span(translate('.header.item'), class: 'govuk-visually-hidden') },
          { text: translate('.header.time_claimed') },
          { text: translate(allow_uplift? ? '.header.net_cost_with_uplift' : '.header.net_cost_claimed'),
            classes: 'govuk-table__header--numeric' },
        ]
      end

      def allow_uplift?
        @claim.reasons_for_claim.include?(ReasonForClaim::ENHANCED_RATES_CLAIMED.to_s)
      end
    end
  end
end
