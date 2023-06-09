const form = document.getElementById('new_steps_letters_calls_form');
const total_for_letters_and_phone_calls = document.getElementById('letters-calls-total');
const letters = document.getElementById('steps-letters-calls-form-letters-field');
const phone_calls = document.getElementById('steps-letters-calls-form-calls-field');
const letter_calls_uplift_checkbox = document.getElementById('steps-letters-calls-form-apply-uplift-true-field');
const letter_calls_uplift_percentage = document.getElementById('steps-letters-calls-form-letters-calls-uplift-field');

// Calculate the total based on the values of letters and phone_calls inputs
function calculateTotal() {
    const lettersValue = parseFloat(letters.value) || 0;
    const phoneCallsValue = parseFloat(phone_calls.value) || 0;
    const unitPriceForLetters = parseFloat(letters.getAttribute('data-rate-letters')) || 0;
    const unitPriceForPhoneCalls = parseFloat(phone_calls.getAttribute('data-rate-phone-calls')) || 0;
    const total = (lettersValue * unitPriceForLetters) + (phoneCallsValue * unitPriceForPhoneCalls);
    return total.toFixed(2); // Format total to two decimal places
}

// Calculate the total with uplift and update the DOM element accordingly
export function calculateTotalWithUplift() {
    const currentTotal = parseFloat(calculateTotal()) || 0;
    const upliftPercentage = parseFloat(letter_calls_uplift_percentage.value) || 0;
    const upliftToAdd = currentTotal * (upliftPercentage / 100);
    const totalWithUplift = (currentTotal + upliftToAdd).toFixed(2); // Format total to two decimal places
    return totalWithUplift;
}

// Update the DOM element with the provided total, or calculate the total if not provided
function updateDomElementTotal() {
    const totalAmount = calculateTotalWithUplift();
    total_for_letters_and_phone_calls.innerHTML = '£' + totalAmount;
}

// Check if all necessary field values exist
function checkIfAllFieldValueExists() {
    return letters.value && phone_calls.value;
}

// Handle change events on the form
function handleFormChange(event) {
    if (checkIfAllFieldValueExists()) {
        if ((event.target === letters || event.target === phone_calls) || (event.target === letter_calls_uplift_percentage && letter_calls_uplift_checkbox.checked)) {
            updateDomElementTotal();
        }
        if (event.target === letter_calls_uplift_checkbox && !letter_calls_uplift_checkbox.checked) {
            letter_calls_uplift_percentage.value = 0;
            updateDomElementTotal();
        }
    }
}

// Attach event listener to the form for change events
if (form && total_for_letters_and_phone_calls && letters && phone_calls) {
    form.addEventListener('change', handleFormChange);
}
