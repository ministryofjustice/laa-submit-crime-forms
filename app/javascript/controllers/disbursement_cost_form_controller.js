// Update the DOM element with the provided total
function updateDomElementTotal(amount, element) {
  let formatedAmount = parseFloat(amount).toFixed(2);
  element.innerHTML = '£' + formatedAmount;
}

// Handle change events on the form
export function handleFormChange(event) {
  const valueField = document.querySelector("[data-selector=valueField]");
  const vatField = document.querySelector("[data-selector=vatField]");

  if ([valueField, vatField].includes(event.target)) {
    const totalWithoutVatField = document.getElementById('total-without-vat')
    const totalWithVatField = document.getElementById('total-with-vat')

    let totalWithoutVat = 0,
      totalWithVat = 0;

    if(!isNaN(valueField.value)) {
      totalWithoutVat = totalWithVat = parseFloat(valueField.value) * parseFloat(valueField.getAttribute('data-multipler'))
      if(vatField.checked) {
        totalWithVat = totalWithoutVat * (1.0 + parseFloat(vatField.getAttribute('data-multipler')))
      }
    }
    updateDomElementTotal(totalWithoutVat, totalWithoutVatField)
    updateDomElementTotal(totalWithVat, totalWithVatField)
  }
}

const form = document.getElementById('new_steps_disbursement_cost_form');
if (form) {
  form.addEventListener('change', (event) => handleFormChange(event));
};
