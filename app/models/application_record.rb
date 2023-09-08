class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def translations(value, key, default=value)
    I18n.available_locales.each_with_object(value: value) do |locale, hash|
      hash[locale] = value.blank? ? nil : I18n.translate("#{key}.#{value}", default: default, locale: locale)
    end
  end
end
