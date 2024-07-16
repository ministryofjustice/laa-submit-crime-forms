// https://frontend.design-system.service.gov.uk/importing-css-assets-and-javascript/#javascript
import { initAll } from 'govuk-frontend'
import accessibleAutocomplete from 'accessible-autocomplete'
import './handle-forms'
import '@hotwired/turbo-rails'
import $ from 'jquery'

initAll()

Turbo.setFormMode('optin')
Turbo.session.drive = false

const $inputs = document.querySelectorAll('[data-module="govuk-input"]')
if ($inputs) {
  for (let i = 0; i < $inputs.length; i++) {
    new Input($inputs[i]).init()
  }
}

// Avoid flickering header menu on small screens
// Refer to `stylesheets/local/custom.scss`
const $headerNavigation = document.querySelector('ul.app-header-menu-hidden-on-load')
if ($headerNavigation) {
  $headerNavigation.classList.remove("app-header-menu-hidden-on-load")
}

convertSelectToAutocomplete()

$(document).on('turbo:render', function () {
  initAll()
  convertSelectToAutocomplete()
})

function convertSelectToAutocomplete(){
  //enhance all tagged select elements to be accessible-autocomplete elements
  const $acElements = document.querySelectorAll('[data-module="accessible-autocomplete"]')
  if ($acElements) {
    for (let i = 0; i < $acElements.length; i++) {
      var convertedToAutocomplete = $acElements[i].getAttribute('data-converted')
      if(!convertedToAutocomplete){
        const name = $acElements[i].getAttribute('data-name')
        accessibleAutocomplete.enhanceSelectElement({
          selectElement: $acElements[i],
          defaultValue: '',
          showNoOptionsFound: name === null,
          name: name,
          autoselect: $acElements[i].getAttribute('data-autoselect') === "true"
        })
        $acElements[i].setAttribute('data-converted', true)
      }
    }
  }
}

// to ensure that the index view has up to date data when the user chnages tab
// we use JS here to reload any visible turboframnes
$(function () {
  var reloader = $('.reload-visible-turboframes')

  if(reloader) {
    var selector = reloader.data('selector')
    $('.reload-visible-turboframes ' + selector).on('click', function () {
      $('turbo-frame:visible')[0].reload()
    })
  }
})
