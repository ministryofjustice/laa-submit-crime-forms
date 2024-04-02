class ApplicationRecord < ActiveRecord::Base
  # Needed as Faker loads a number of unrelated locales
  RENDERED_LOCALES = %i[en].freeze

  primary_abstract_class

  def translations(value, key, default = value)
    RENDERED_LOCALES.each_with_object(value:) do |locale, hash|
      hash[locale] = value.blank? ? nil : I18n.t("#{key}.#{value}", default:, locale:)
    end
  end
end
