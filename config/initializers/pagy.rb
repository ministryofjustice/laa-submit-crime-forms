require 'pagy/extras/array'

Pagy::DEFAULT[:items] = 10
Pagy::I18n.load(locale: "en", filepath: Rails.root.join("config/locales/en/pagy.yml"))