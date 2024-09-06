module Nsm
  module CheckAnswers
    class CostSummaryCard < Base
      PROFIT_COSTS = 'profit_costs'.freeze
      # NOTE: nil values do NOT render a table cell
      SKIP_CELL = nil

      attr_reader :claim, :show_adjustments, :has_card

      def initialize(claim, show_adjustments: SKIP_CELL, has_card: true, title_key: 'title')
        @claim = claim
        @show_adjustments = show_adjustments
        @has_card = has_card
        @group = 'about_claim'
        @section = 'cost_summary'
        @title_key = title_key
      end

      def title(**)
        I18n.t("nsm.steps.check_answers.groups.#{group}.#{section}.#{@title_key}", **)
      end

      def custom
        { partial: 'nsm/steps/view_claim/cost_summary', locals: { section: self } }
      end

      def headers
        [
          t('items_html', numeric: false),
          t('request_net'), t('request_vat'), t('request_gross'),
          show_adjustments && t('allowed_net'),
          show_adjustments && t('allowed_vat'),
          show_adjustments && t('allowed_gross')
        ]
      end

      def table_fields(formatted: true)
        [
          calculate_profit_costs(formatted:),
          calculate_disbursements(formatted:),
          calculate_travel(formatted:),
          calculate_waiting(formatted:),
        ]
      end

      def footer_fields
        {
          name: t('total', numeric: false),
          net_cost: format(data_for_footer.sum { _1[:net_cost] }, accessibility_key: 'net_cost'),
          vat: format(data_for_footer.sum { _1[:vat] }, accessibility_key: 'vat'),
          gross_cost: format(total_gross, accessibility_key: 'gross_cost'),
          allowed_net_cost: format(sum_allowed(data_for_footer, :allowed_net_cost), accessibility_key: 'allowed_net_cost'),
          allowed_vat: format(sum_allowed(data_for_footer, :allowed_vat), accessibility_key: 'allowed_vat'),
          allowed_gross_cost: format(total_gross_allowed, accessibility_key: 'allowed_gross_cost'),
        }
      end

      def change_link_controller_method
        :show
      end

      def total_gross
        data_for_footer.sum { _1[:gross_cost] }
      end

      def total_gross_allowed
        sum_allowed(data_for_footer, :allowed_gross_cost)
      end

      def show_adjusted?
        return false unless claim.granted? || claim.part_grant?

        total_gross_allowed != total_gross
      end

      private

      def data_for_footer
        @data_for_footer ||= table_fields(formatted: false)
      end

      def sum_allowed(data, field)
        show_adjustments && data.sum { _1[field] }
      end

      def calculate_profit_costs(formatted:)
        letters_calls = LettersAndCallsCosts::TotalCostAlias.new(claim)

        calculate_work_item_row('profit_costs', formatted: formatted, extra_rows: [letters_calls])
      end

      def calculate_waiting(formatted:)
        calculate_work_item_row('waiting', formatted:)
      end

      def calculate_travel(formatted:)
        calculate_work_item_row('travel', formatted:)
      end

      def calculate_disbursements(formatted:)
        net_cost = disbursements.sum(&:total_cost_pre_vat)
        gross_cost = disbursements.sum(&:total_cost)
        vat = gross_cost - net_cost
        allowed_net_cost = show_adjustments && disbursements.sum(&:allowed_total_cost_pre_vat)
        allowed_gross_cost = show_adjustments && disbursements.sum(&:allowed_total_cost)
        allowed_vat = show_adjustments && (allowed_gross_cost - allowed_net_cost)

        build_hash(
          name: t('disbursements', numeric: false),
          net_cost: net_cost,
          vat: vat,
          allowed_net_cost: allowed_net_cost,
          allowed_vat: allowed_vat,
          formatted: formatted
        )
      end

      def calculate_work_item_row(name, formatted:, extra_rows: [])
        claimed_rows = work_items_matching(name, type_type: :claimed) + extra_rows
        allowed_rows = work_items_matching(name, type_type: :assessed) + extra_rows

        net_cost = claimed_rows.sum { _1.total_cost || 0 }
        allowed_net_cost = show_adjustments ? allowed_rows.sum { _1.allowed_total_cost || 0 } : nil

        build_hash(
          name: name_row(name, claimed_rows.any? { !_1.in?(allowed_rows) }),
          net_cost: net_cost,
          vat: net_cost * vat_rate,
          allowed_net_cost: allowed_net_cost,
          allowed_vat: allowed_net_cost && (allowed_net_cost * vat_rate),
          formatted: formatted
        )
      end

      def build_hash(name:, net_cost:, vat:, allowed_net_cost:, allowed_vat:, formatted:)
        {
          name: name,
          net_cost: format(net_cost, formatted:),
          vat: format(vat, formatted:),
          gross_cost: format(net_cost + vat, formatted:),
          allowed_net_cost: format(allowed_vat && allowed_net_cost, formatted:),
          allowed_vat: format(allowed_vat, formatted:),
          allowed_gross_cost: format(allowed_vat && (allowed_net_cost + allowed_vat), formatted:),
        }
      end

      def disbursements
        @disbursements ||= claim.disbursements
      end

      def work_items_matching(group_type, type_type:)
        field = type_type == :assessed ? :assessed_work_type : :work_type
        claim.work_items.select do |work_item|
          relevant_type = work_item.send(field)
          candidate_group_type = relevant_type.in?(%w[travel waiting]) ? relevant_type : PROFIT_COSTS
          candidate_group_type == group_type
        end
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
          text: I18n.t("nsm.steps.check_answers.groups.cost_summary.#{scope}.#{key}").html_safe,
          numeric: numeric, width: width
        }
      end

      def name_row(name, work_type_changed)
        return t(name, numeric: false) unless work_type_changed && show_adjustments

        span = tag.span(I18n.t("nsm.steps.check_answers.groups.cost_summary.with_adjustments.#{name}"),
                        title: I18n.t('nsm.work_items.type_changes.types_changed'))
        sup = tag.sup do
          tag.a(I18n.t('nsm.work_items.type_changes.asterisk'), href: '#fn*')
        end

        {
          text:  safe_join([span, ' ', sup]),
          numeric: false
        }
      end
    end
  end
end
