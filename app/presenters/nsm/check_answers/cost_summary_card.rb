module Nsm
  module CheckAnswers
    class CostSummaryCard < Base
      PROFIT_COSTS = 'profit_costs'.freeze
      # NOTE: nil values do NOT render a table cell
      SKIP_CELL = nil

      attr_reader :claim, :show_adjustments, :has_card

      def initialize(claim, show_adjustments: SKIP_CELL, has_card: true)
        @claim = claim
        @show_adjustments = show_adjustments
        @has_card = has_card
        @group = 'about_claim'
        @section = 'cost_summary'
      end

      def title(**)
        I18n.t("nsm.steps.check_answers.groups.#{group}.#{section}.title", **)
      end

      def custom
        { partial: 'nsm/steps/view_claim/cost_summary', locals: { section: self } }
      end

      def headers
        [
          t('items', numeric: false, width: 'govuk-!-width-one-quarter'),
          t('request_net'), t('request_vat'), t('request_gross'),
          show_adjustments && t('allowed_net'),
          show_adjustments && t('allowed_vat'),
          show_adjustments && t('allowed_gross')
        ]
      end

      def table_fields(formatted: true)
        [
          calculate_profit_costs(formatted:),
          calculate_waiting(formatted:),
          calculate_travel(formatted:),
          calculate_disbursements(formatted:),
        ]
      end

      def summed_fields
        data = table_fields(formatted: false)

        {
          name: t('total', numeric: false),
          net_cost: format(data.sum { _1[:net_cost] }, accessibility_key: 'net_cost'),
          vat: format(data.sum { _1[:vat] }, accessibility_key: 'vat'),
          gross_cost: format(data.sum { _1[:gross_cost] }, accessibility_key: 'gross_cost'),
          allowed_net_cost: format(sum_allowed(data, :allowed_net_cost), accessibility_key: 'allowed_net_cost'),
          allowed_vat: format(sum_allowed(data, :allowed_vat), accessibility_key: 'allowed_vat'),
          allowed_gross_cost: format(sum_allowed(data, :allowed_gross_cost), accessibility_key: 'allowed_gross_cost'),
        }
      end

      def change_link_controller_method
        :show
      end

      private

      def sum_allowed(data, field)
        show_adjustments && data.sum { _1[field] }
      end

      def calculate_profit_costs(formatted:)
        letters_calls = LettersAndCallsCosts::TotalCostAlias.new(claim)

        calculate_row((work_items[PROFIT_COSTS] || []) + [letters_calls], 'profit_costs', formatted:)
      end

      def calculate_waiting(formatted:)
        calculate_row(work_items['waiting'] || [], 'waiting', formatted:)
      end

      def calculate_travel(formatted:)
        calculate_row(work_items['travel'] || [], 'travel', formatted:)
      end

      def calculate_disbursements(formatted:)
        net_cost = disbursements.sum(&:total_cost_pre_vat)
        gross_cost = disbursements.sum(&:total_cost)
        vat = gross_cost - net_cost
        allowed_net_cost = show_adjustments && disbursements.sum(&:allowed_total_cost_pre_vat)
        allowed_gross_cost = show_adjustments && disbursements.sum(&:allowed_total_cost)
        allowed_vat = show_adjustments && (allowed_gross_cost - allowed_net_cost)

        build_hash(
          name: 'disbursements',
          net_cost: net_cost,
          vat: vat,
          allowed_net_cost: allowed_net_cost,
          allowed_vat: allowed_vat,
          formatted: formatted
        )
      end

      def calculate_row(rows, name, formatted:)
        net_cost = rows.sum { _1.total_cost || 0 }
        allowed_net_cost = show_adjustments ? rows.sum { _1.allowed_total_cost || 0 } : nil

        build_hash(
          name: name,
          net_cost: net_cost,
          vat: net_cost * vat_rate,
          allowed_net_cost: allowed_net_cost,
          allowed_vat: allowed_net_cost && (allowed_net_cost * vat_rate),
          formatted: formatted
        )
      end

      def build_hash(name:, net_cost:, vat:, allowed_net_cost:, allowed_vat:, formatted:)
        {
          name: t(name, numeric: false),
          net_cost: format(net_cost, formatted:),
          vat: format(vat, formatted:),
          gross_cost: format(net_cost + vat, formatted:),
          allowed_net_cost: format(allowed_vat && allowed_net_cost, formatted:),
          allowed_vat: format(allowed_vat, formatted:),
          allowed_gross_cost: format(allowed_vat && (allowed_net_cost + allowed_vat), formatted:),
        }
      end

      def work_items
        @work_items ||= claim.work_items.group_by { |work_item| group_type(work_item.work_type.to_s) }
      end

      def disbursements
        @disbursements ||= claim.disbursements
      end

      def group_type(work_type)
        work_type.in?(%w[travel waiting]) ? work_type : PROFIT_COSTS
      end

      def vat_rate
        @vat_rate ||= claim.firm_office.vat_registered == 'yes' ? Pricing.for(claim).vat : 0.0
      end

      def format(value, formatted: true, accessibility_key: '')
        return value unless formatted
        return nil if value.nil?

        if accessibility_key.present?
          { text: accessible_text(accessibility_key, NumberTo.pounds(value)), numeric: true }
        else
          { text: NumberTo.pounds(value), numeric: true }
        end
      end

      def accessible_text(key, value)
        scope = show_adjustments ? 'with_adjustments' : 'base'

        text = I18n.t("nsm.steps.check_answers.groups.cost_summary.#{scope}.accessibility.#{key}")
        sanitize("#{govuk_visually_hidden(text)} #{value}")
      end

      def t(key, numeric: true, width: nil)
        scope = show_adjustments ? 'with_adjustments' : 'base'
        {
          text: I18n.t("nsm.steps.check_answers.groups.cost_summary.#{scope}.#{key}"),
          numeric: numeric, width: width
        }
      end
    end
  end
end
