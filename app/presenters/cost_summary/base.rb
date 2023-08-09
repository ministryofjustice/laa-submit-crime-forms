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
  end
end
