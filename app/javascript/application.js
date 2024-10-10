// https://frontend.design-system.service.gov.uk/importing-css-assets-and-javascript/#javascript
import { initAll } from "govuk-frontend";
import "./handle-forms";
import { convertSelectToAutocomplete } from "./autocomplete.js";
import "@hotwired/turbo-rails";
import $ from "jquery";

initAll();

Turbo.setFormMode("optin");
Turbo.session.drive = false;

const $inputs = document.querySelectorAll('[data-module="govuk-input"]');
if ($inputs) {
  for (let i = 0; i < $inputs.length; i++) {
    new Input($inputs[i]).init();
  }
}

// Avoid flickering header menu on small screens
// Refer to `stylesheets/local/custom.scss`
const $headerNavigation = document.querySelector(
  "ul.app-header-menu-hidden-on-load",
);
if ($headerNavigation) {
  $headerNavigation.classList.remove("app-header-menu-hidden-on-load");
}

convertSelectToAutocomplete();

// Most of this Turbo setup code is needed for the multi-form gem
$(document).on("turbo:render", function () {
  initAll();
  convertSelectToAutocomplete();
});
