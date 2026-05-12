require 'pagy/extras/array'
require 'pagy/countless'
require 'pagy/extras/overflow'

Pagy::DEFAULT[:items] = 10
Pagy::I18n.load(locale: 'en', filepath: Rails.root.join('config/locales/en/pagy.yml'))
