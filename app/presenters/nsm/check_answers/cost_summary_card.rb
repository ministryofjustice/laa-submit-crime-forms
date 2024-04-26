# frozen_string_literal: true

module Nsm
  module CheckAnswers
    class CostSummaryCard < Base
      PROFIT_COSTS = 'profit_costs'.freeze
      # NOTE: nil values do NOT render a table cell
      SKIP_CELL = nil

      attr_reader :claim, :work_items, :show_adjustments

      def initialize(claim, show_adjustments: SKIP_CELL)
        @claim = claim
        @show_adjustments = show_adjustments
        @group = 'about_claim'
        @section = 'cost_summary'
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

      def template
        'nsm/steps/view_claim/cost_summary'
      end

      def headers
        base = [
          t('items', numeric: false, width: 'govuk-!-width-one-quarter'),
          t('request_net'),
          t('request_vat'),
          t('request_gross'),
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
          calculate_disbursements(formatted:)
        ]
      end

      def summed_fields
        data = table_fields(formatted: false)

        {
          name: t('total', numeric: false),
          net_cost: format(data.sum { _1[:net_cost] }),
          vat: format(data.sum { _1[:vat] }),
          gross_cost: format(data.sum { _1[:gross_cost] }),
          allowed_net_cost: format(sum_allowed(data, :net_cost)),
          allowed_vat: format(sum_allowed(data, :vat)),
          allowed_gross_cost: format(sum_allowed(data, :gross_cost)),
        }
      end

      private

      def sum_allowed(data, field)
        show_adjustments && data.sum { _1[field] }
      end

      def calculate_profit_costs(formatted:)
        letters_calls = Nsm::Steps::LettersCallsForm.build(claim)

        calculate_row((work_items[PROFIT_COSTS] || []) + [letters_calls], 'profit_costs', formatted:)
      end

      def calculate_waiting(formatted:)
        calculate_row(work_items['waiting'] || [], 'waiting', formatted:)
      end

      def calculate_travel(formatted:)
        calculate_row(work_items['travel'] || [], 'travel', formatted:)
      end

      def calculate_disbursements(formatted:)
        net_cost = disbursements.total_cost
        vat = disbursements.total_cost_inc_vat - disbursements.total_cost
        allowed_net_cost = show_adjustments && disbursements.total_cost
        allowed_vat = show_adjustments && (disbursements.total_cost_inc_vat - disbursements.total_cost)

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
        allowed_net_cost = show_adjustments ? rows.sum { _1.total_cost || 0 } : nil

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
        @work_items ||= Nsm::CostSummary::WorkItems.new(claim.work_items, claim).work_item_forms
                                                   .group_by { |work_item| group_type(work_item.work_type.to_s) }
      end

      def disbursements
        @disbursements ||= Nsm::CostSummary::Disbursements.new(claim.disbursements, claim)
      end

      def group_type(work_type)
        return work_type if work_type.in?(%w[travel waiting])

        PROFIT_COSTS
      end

      def vat_rate
        @vat_rate ||=
          if claim.firm_office.vat_registered == 'yes'
            Pricing.for(claim).vat
          else
            0.0
          end
      end

      def format(value, formatted: true)
        return value unless formatted
        return nil if value.nil?

        { text: NumberTo.pounds(value), numeric: true }
      end

      def t(key, numeric: true, width: nil)
        scope = show_adjustments ? 'with_adjustments' : 'base'
        {
          text: I18n.t("nsm.steps.check_answers.groups.cost_summary.#{scope}.#{key}"),
          numeric: numeric,
          width: width
        }
      end
    end
  end
end
