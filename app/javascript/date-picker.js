
import MOJFrontend from '@ministryofjustice/frontend'
import $ from 'jquery'
window.$ = $

function init() {
  [...document.querySelectorAll('[data-module="moj-date-picker"]')].forEach(picker => {
    new MOJFrontend.DatePicker(picker, {}).init()
  });
}

document.addEventListener('DOMContentLoaded', init);
