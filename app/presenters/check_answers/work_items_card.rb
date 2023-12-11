# frozen_string_literal: true

module CheckAnswers
  class WorkItemsCard < Base
    attr_reader :claim, :work_items

    def initialize(claim)
      @claim = claim
      @work_items = CostSummary::WorkItems.new(claim.work_items, claim)
      @vat_rate = vat_rate(claim)
      @group = 'about_claim'
      @section = 'work_items'
    end

    def title(**)
      ApplicationController.helpers.sanitize(
        [
          I18n.t("steps.check_answers.groups.#{group}.#{section}.title", **),
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
          head_key: row[:key][:text],
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
      format_total(work_items.work_item_forms.sum { |item| item_plus_vat(item) })
    end

    def format_total(value)
      text = "<strong>#{currency_value(value)}</strong>"
      ApplicationController.helpers.sanitize(text, tags: %w[strong])
    end

    def currency_value(value)
      NumberTo.pounds(value || 0)
    end

    def item_plus_vat(item)
      (item.total_cost * @vat_rate) + item.total_cost
    end

    def vat_rate(claim)
      Pricing.for(claim)[:vat]
    end
  end
end
