function init() {
  const calculateChangeButton = document.getElementById('calculate_change_button');
  const page = calculateChangeButton?.getAttribute('data-page');
  const lettersAndCallsAdjustmentContainer = document.getElementById('letters-and-calls-adjustment-container');
  const countField = document.getElementById(`letters-calls-form-${page}-count-field`);
  const caseworkerAdjustedValue = document.getElementById('letters_calls_caseworker_allowed_amount');
  const upliftNoField = document.getElementById(`letters-calls-form-${page}-uplift-no-field`);

  if (lettersAndCallsAdjustmentContainer && countField) {
    updateDomElements();
    calculateChangeButton.addEventListener('click', handleTestButtonClick);
  }

  function handleTestButtonClick(event) {
    event.preventDefault();
    updateDomElements();
  }

  function updateDomElements() {
    const totalPrice = calculateAdjustedAmount();
    caseworkerAdjustedValue.innerHTML = totalPrice;
  }

  function calculateAdjustedAmount() {
    const count = countField?.value;
    const unitPrice = calculateChangeButton?.getAttribute('data-unit-price');
    const upliftAmount = calculateChangeButton?.getAttribute('data-uplift-amount');

    if (upliftAmount && upliftNoField.checked) {
      const upliftFactor = (parseFloat(upliftAmount) / 100) + 1;
      return (`£${(count * unitPrice * upliftFactor).toFixed(2)}`);
    } else {
      return (`£${(count * unitPrice).toFixed(2)}`);
    }
  }
}

document.addEventListener('DOMContentLoaded', init);
