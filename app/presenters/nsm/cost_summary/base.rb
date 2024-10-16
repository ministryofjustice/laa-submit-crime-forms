module Nsm
  module CostSummary
    class Base
      include ActionView::Helpers::NumberHelper
      include ActionView::Helpers::TagHelper
      include LaaMultiStepForms::CheckMissingHelper
      MIDDLE_COLUMN = true

      def translate(key, **)
        if key[0] == ('.')
          I18n.t("summary.#{key}", **)
        else
          I18n.t("summary.#{self.class::TRANSLATION_KEY.to_s.underscore}.#{key}", **)
        end
      end

      def vat_rate
        Pricing.for(@claim).vat
      end

      def vat_registered
        @claim.firm_office.vat_registered == YesNoAnswer::YES.to_s
      end

      def caption
        translate('caption')
      end

      def total_cost_cell
        safe_join([tag.span(translate('net_cost'), class: 'govuk-visually-hidden'),
                   tag.strong(NumberTo.pounds(total_cost))])
      end

      def footer_row
        [
          { text: translate('.footer.total'), classes: 'govuk-table__header' },
          ({} if self.class::MIDDLE_COLUMN),
          { text: total_cost_cell, classes: 'govuk-table__cell--numeric govuk-summary-list__value-bold' }
        ].compact
      end
    end
  end
end
