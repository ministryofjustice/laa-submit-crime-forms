// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

// https://frontend.design-system.service.gov.uk/importing-css-assets-and-javascript/#javascript
import { initAll } from 'govuk-frontend'
import { } from './controllers/disbursement_cost_form_controller'
initAll()

const $inputs = document.querySelectorAll('[data-module="govuk-input"]')
if ($inputs) {
  for (let i = 0; i < $inputs.length; i++) {
    new Input($inputs[i]).init()
  }
}

import accessibleAutocomplete from 'accessible-autocomplete'

const $acElements = document.querySelectorAll('[data-module="accessible-autocomplete"]')
if ($acElements) {
  for (let i = 0; i < $acElements.length; i++) {
    accessibleAutocomplete.enhanceSelectElement({
      selectElement: $acElements[i],
      defaultValue: '',
      showNoOptionsFound: false,
      name: $acElements[i].getAttribute('data-name')

    })
  }
}

// Avoid flickering header menu on small screens
// Refer to `stylesheets/local/custom.scss`
const $headerNavigation = document.querySelector('ul.app-header-menu-hidden-on-load')
if ($headerNavigation) {
  $headerNavigation.classList.remove("app-header-menu-hidden-on-load")
}
