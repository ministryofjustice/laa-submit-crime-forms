// https://frontend.design-system.service.gov.uk/importing-css-assets-and-javascript/#javascript
import { initAll } from "govuk-frontend";
import "./handle-forms";
import "./date-picker";
import "@hotwired/turbo-rails";
import $ from "jquery";
import { checkAndHandleResizeOnScrollablePane } from "./scrollable_pane";
import { convertSelectToAutocomplete } from "./autocomplete.js";

initAll();

// Most of this Turbo setup code is needed for the multi-form capabilities
Turbo.setFormMode("optin");
Turbo.session.drive = false;

[...document.querySelectorAll('[data-module="govuk-input"]')].forEach((input) =>
  new Input(input).init(),
);

// Avoid flickering header menu on small screens
// Refer to `stylesheets/local/custom.scss`
[...document.querySelectorAll("ul.app-header-menu-hidden-on-load")].forEach(
  (header) => header.classList.remove("app-header-menu-hidden-on-load"),
);

convertSelectToAutocomplete();

document.addEventListener(
  "DOMContentLoaded",
  checkAndHandleResizeOnScrollablePane,
);
window.addEventListener("resize", checkAndHandleResizeOnScrollablePane);

$(document).on("turbo:render", function () {
  initAll();
  convertSelectToAutocomplete();
});
