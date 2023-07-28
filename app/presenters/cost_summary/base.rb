module CostSummary
  class Base
    include ActionView::Helpers::NumberHelper

    def translate(key, **opt)
      if key[0] == ('.')
        I18n.t("summary.#{key}", **opt)
      else
        I18n.t("summary.#{self.class::TRANSLATION_KEY.to_s.underscore}.#{key}", **opt)
      end
    end
  end
end
