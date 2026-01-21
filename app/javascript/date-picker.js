import { DatePicker } from '@ministryofjustice/frontend'

function init() {
  [...document.querySelectorAll('[data-module="moj-date-picker"]')].forEach((picker) => new DatePicker(picker, {}));
}

document.addEventListener('DOMContentLoaded', init);
