module CostSummary
  class Base
    include ActionView::Helpers::NumberHelper

    def t(key, **opt)
      if key[0] == ('.')
        I18n.t("summary.#{key}", **opt)
      else
        I18n.t("summary.#{self.class.to_s.underscore}.#{key}", **opt)
      end
    end

    def f(value)
      number_to_currency(value, unit: '£')
    end
  end
end
