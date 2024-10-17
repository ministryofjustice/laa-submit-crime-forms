
import MOJFrontend from '@ministryofjustice/frontend'
import $ from 'jquery'
window.$ = $

function init() {
  const $datepickers = document.querySelectorAll('[data-module="moj-date-picker"]')
  MOJFrontend.nodeListForEach($datepickers, function ($datepicker) {
    new MOJFrontend.DatePicker($datepicker, {}).init();
  })
}

document.addEventListener('DOMContentLoaded', init);
