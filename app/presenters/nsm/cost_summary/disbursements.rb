module Nsm
  module CostSummary
    class Disbursements < Base
      TRANSLATION_KEY = self
      attr_reader :disbursements, :claim

      def initialize(disbursements, claim)
        @claim = claim
        @disbursements = disbursements
        super()
      end

      def rows
        disbursements.map do |disbursement|
          [
            { text: translated_text(disbursement), classes: 'govuk-table__header' },
            { text: NumberTo.pounds(disbursement.total_cost_pre_vat || 0), classes: 'govuk-table__cell--numeric' },
            { text: NumberTo.pounds(disbursement.vat || 0), classes: 'govuk-table__cell--numeric' },
            { text: NumberTo.pounds(disbursement.total_cost || 0), classes: 'govuk-table__cell--numeric' },
          ]
        end
      end

      def total_cost
        @total_cost ||= claim.totals.dig(:cost_summary, :disbursements, :claimed_total_inc_vat)
      end

      def net_cost
        @net_cost ||= claim.totals.dig(:cost_summary, :disbursements, :claimed_total_exc_vat)
      end

      def vat_amount
        @vat_amount ||= claim.totals.dig(:cost_summary, :disbursements, :claimed_vat)
      end

      def title
        translate('disbursements')
      end

      def translated_text(disbursement)
        check_missing(disbursement.translated_disbursement_type)
      end

      def header_row
        [
          { text: translate('.header.item') },
          { text: translate('.header.net_cost'), classes: 'govuk-table__header--numeric' },
          { text: translate('.header.vat_on_claimed'), classes: 'govuk-table__header--numeric' },
          { text: translate('.header.total_claimed'), classes: 'govuk-table__header--numeric' },
        ]
      end

      def footer_row
        [
          { text: translate('.footer.total'), classes: 'govuk-table__header' },
          { text: total_cost_cell, classes: 'govuk-table__cell--numeric govuk-summary-list__value-bold' },
          { text: vat_amount_cell, classes: 'govuk-table__cell--numeric govuk-summary-list__value-bold' },
          { text: gross_total_cost_cell, classes: 'govuk-table__cell--numeric govuk-summary-list__value-bold' }
        ].compact
      end

      def total_cost_cell
        safe_join([tag.span(translate('.header.total_claimed'), class: 'govuk-visually-hidden'),
                   tag.strong(NumberTo.pounds(net_cost))])
      end

      def gross_total_cost_cell
        safe_join([tag.span(translate('.header.net_cost_claimed'), class: 'govuk-visually-hidden'),
                   tag.strong(NumberTo.pounds(total_cost))])
      end

      def vat_amount_cell
        safe_join([tag.span(translate('.header.vat_on_claimed'), class: 'govuk-visually-hidden'),
                   tag.strong(NumberTo.pounds(vat_amount))])
      end

      def disbursement_summary_footer_row
        [
          [
            { text: translate('disbursements'), classes: 'govuk-table__header' },
            { text: total_cost_cell, classes: 'govuk-table__cell--numeric govuk-summary-list__value-bold' },
            { text: vat_amount_cell, classes: 'govuk-table__cell--numeric govuk-summary-list__value-bold' },
            { text: gross_total_cost_cell, classes: 'govuk-table__cell--numeric govuk-summary-list__value-bold' }
          ].compact
        ]
      end

      def disbursement_summary_header_row
        [
          { text: tag.span(translate('.header.item'), class: 'govuk-visually-hidden') },
          { text: translate('.header.net_cost_claimed'),
            classes: 'govuk-table__header--numeric' },
          { text: translate('.header.vat_on_claimed'),
            classes: 'govuk-table__header--numeric' },
          { text: translate('.header.total_claimed'),
            classes: 'govuk-table__header--numeric' },
        ]
      end
    end
  end
end
