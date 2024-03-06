# frozen_string_literal: true

module Nsm
  module CheckAnswers
    class WorkItemsCard < Base
      attr_reader :claim, :work_items

      def initialize(claim)
        @claim = claim
        @work_items = Nsm::CostSummary::WorkItems.new(claim.work_items, claim)
        @group = 'about_claim'
        @section = 'work_items'
      end

      def title(**)
        ApplicationController.helpers.sanitize(
          [
            I18n.t("nsm.steps.check_answers.groups.#{group}.#{section}.title", **),
            check_missing(claim.work_items.any?) { nil },
          ].compact.join(' '),
          tags: %w[strong]
        )
      end

      def row_data
        header_rows + work_item_rows + total_rows
      end

      private

      def header_rows
        [
          {
            head_key: 'items',
            text: ApplicationController.helpers.sanitize(translate_table_key(section, 'items_total'), tags: %w[strong])
          }
        ]
      end

      def work_item_rows
        work_items.rows.map do |row|
          {
            head_opts: { text: row[:key][:text] },
            text: row[:value][:text]
          }
        end
      end

      def total_rows
        if @claim.firm_office.vat_registered == YesNoAnswer::YES.to_s
          [
            {
              head_key: 'total',
              text: work_item_total,
              footer: true
            },
            {
              head_key: 'total_inc_vat',
              text: work_item_total_inc_vat
            },
          ]
        else
          [
            {
              head_key: 'total',
              text: work_item_total,
              footer: true
            }
          ]
        end
      end

      def work_item_total
        format_total(work_items.total_cost)
      end

      def work_item_total_inc_vat
        format_total(work_items.total_cost_inc_vat)
      end
    end
  end
end
