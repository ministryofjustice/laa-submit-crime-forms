class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  def translations(value, key, default = value)
    (I18n.available_locales & [:en]).each_with_object(value:) do |locale, hash|
      hash[locale] = value.blank? ? nil : I18n.t("#{key}.#{value}", default:, locale:)
    end
  end
end
