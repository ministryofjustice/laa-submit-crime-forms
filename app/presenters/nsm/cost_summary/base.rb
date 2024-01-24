module Nsm
  module CostSummary
    class Base
      include ActionView::Helpers::NumberHelper
      include LaaMultiStepForms::CheckMissingHelper

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
    end
  end
end
