module Nsm
  module CheckAnswers
    class CostSummaryCard < Base
      PROFIT_COSTS = 'profit_costs'.freeze
      # NOTE: nil values do NOT render a table cell
      SKIP_CELL = nil

      attr_reader :claim, :show_adjustments, :has_card

      def initialize(claim, show_adjustments: SKIP_CELL, has_card: true, title_key: 'title', skip_links: false)
        @claim = claim
        @show_adjustments = show_adjustments
        @has_card = has_card
        @group = 'about_claim'
        @section = 'cost_summary'
        @title_key = title_key
        @skip_links = skip_links
        super()
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

      def table_fields
        [
          build_row(:profit_costs),
          build_row(:disbursements),
          build_row(:travel),
          build_row(:waiting),
        ]
      end

      def footer_fields
        totals = claim.totals[:totals]
        {
          name: t('total', numeric: false),
          net_cost: format(totals[:claimed_total_exc_vat], accessibility_key: 'net_cost'),
          vat: format(totals[:claimed_vat], accessibility_key: 'vat'),
          gross_cost: format(total_gross, accessibility_key: 'gross_cost'),
          allowed_net_cost: format_allowed(totals[:assessed_total_exc_vat], accessibility_key: 'allowed_net_cost'),
          allowed_vat: format_allowed(totals[:assessed_vat], accessibility_key: 'allowed_vat'),
          allowed_gross_cost: format_allowed(total_gross_allowed, accessibility_key: 'allowed_gross_cost'),
        }
      end

      def change_link_controller_method
        :show
      end

      def total_gross
        claim.totals[:totals][:claimed_total_inc_vat]
      end

      def total_gross_allowed
        claim.totals[:totals][:assessed_total_inc_vat]
      end

      delegate :show_adjusted?, to: :claim

      private

      def format_allowed(value, accessibility_key: '')
        show_adjustments && format(value, accessibility_key:)
      end

      def build_row(type)
        data = claim.totals[:cost_summary][type]

        {
          name: name_row(type,
                         work_type_changed: data[:at_least_one_claimed_work_item_assessed_as_type_with_different_summary_group]),
          net_cost: format(data[:claimed_total_exc_vat]),
          vat: format(data[:claimed_vat]),
          gross_cost: format(data[:claimed_total_inc_vat]),
          allowed_net_cost: format_allowed(data[:assessed_total_exc_vat]),
          allowed_vat: format_allowed(data[:assessed_vat]),
          allowed_gross_cost: format_allowed(data[:assessed_total_inc_vat]),
        }.compact
      end

      def format(value, accessibility_key: '')
        if accessibility_key.present?
          { text: accessible_text(accessibility_key, LaaCrimeFormsCommon::NumberTo.pounds(value)), numeric: true }
        else
          { text: LaaCrimeFormsCommon::NumberTo.pounds(value), numeric: true }
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

      def name_row(type, work_type_changed: false)
        return t(type, numeric: false) unless work_type_changed && show_adjustments

        span = tag.span(I18n.t("nsm.steps.check_answers.groups.cost_summary.with_adjustments.#{type}"),
                        title: I18n.t('nsm.work_items.type_changes.types_changed'))
        sup = tag.sup do
          if @skip_links
            I18n.t('nsm.work_items.type_changes.asterisk')
          else
            tag.a(I18n.t('nsm.work_items.type_changes.asterisk'), href: '#fn*')
          end
        end

        {
          text:  safe_join([span, ' ', sup]),
          numeric: false
        }
      end
    end
  end
end
