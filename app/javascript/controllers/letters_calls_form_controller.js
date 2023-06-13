// Get the value of an element attribute as a number or a default value
function getAttributeAsNumber(element, attributeName, defaultValue = 0) {
	return parseFloat(element.getAttribute(attributeName)) || defaultValue;
}

// Calculate the total based on the values of letters and phone_calls inputs
function calculateTotal(lettersValue, phoneCallsValue, unitPriceForLetters, unitPriceForPhoneCalls) {
	const total = lettersValue * unitPriceForLetters + phoneCallsValue * unitPriceForPhoneCalls;
	return parseFloat(total.toFixed(2)); // Format total to two decimal places
}

// Calculate the total with uplift
function calculateTotalWithUplift(currentTotal, upliftPercentage) {
	const upliftToAdd = currentTotal * (upliftPercentage / 100);
	const totalWithUplift = (currentTotal + upliftToAdd);
	return totalWithUplift;
}

// Update the DOM element with the provided total
function updateDomElementTotal(totalAmount, element) {
	totalAmount = parseFloat(totalAmount).toFixed(2);
	element.innerHTML = '£' + totalAmount;
}

// Check if all necessary field values exist
function checkIfAllFieldValueExists(lettersValue, phoneCallsValue) {
	return lettersValue && phoneCallsValue;
}

// Handle change events on the form
export function handleFormChange(event, form, totalElement, lettersElement, phoneCallsElement, upliftCheckboxElement, upliftPercentageElement) {
	const lettersValue = parseFloat(lettersElement.value) || 0;
	const phoneCallsValue = parseFloat(phoneCallsElement.value) || 0;
	const unitPriceForLetters = getAttributeAsNumber(lettersElement, 'data-rate-letters');
	const unitPriceForPhoneCalls = getAttributeAsNumber(phoneCallsElement, 'data-rate-phone-calls');
	const upliftPercentage = parseFloat(upliftPercentageElement.value) || 0;

	if (checkIfAllFieldValueExists(lettersValue, phoneCallsValue)) {
		const currentTotal = calculateTotal(lettersValue, phoneCallsValue, unitPriceForLetters, unitPriceForPhoneCalls);
		// Triggered when letters or phone calls value changes, or when uplift percentage changes
		if ([lettersElement, phoneCallsElement, upliftPercentageElement].includes(event.target)) {
			// Update total
			const totalWithUplift = calculateTotalWithUplift(currentTotal, upliftPercentage);
			updateDomElementTotal(totalWithUplift, totalElement);
		}
		if (event.target === upliftCheckboxElement && !upliftCheckboxElement.checked) {
			// Clear uplift percentage value
			upliftPercentageElement.value = '';
			// Update total
			const totalWithUplift = calculateTotalWithUplift(currentTotal, 0);
			updateDomElementTotal(totalWithUplift, totalElement);
		}
	}
}

// Attach event listener to the form for change events
function initializeForm(
	form,
	totalElement,
	lettersElement,
	phoneCallsElement,
	upliftCheckboxElement,
	upliftPercentageElement
) {
	form.addEventListener('change', (event) => handleFormChange(
		event,
		form,
		totalElement,
		lettersElement,
		phoneCallsElement,
		upliftCheckboxElement,
		upliftPercentageElement
	));
}

const form = document.getElementById('new_steps_letters_calls_form');
const total_for_letters_and_phone_calls = document.getElementById('letters-calls-total');
const letters = document.getElementById('steps-letters-calls-form-letters-field');
const phone_calls = document.getElementById('steps-letters-calls-form-calls-field');
const letter_calls_uplift_checkbox = document.getElementById('steps-letters-calls-form-apply-uplift-true-field');
const letter_calls_uplift_percentage = document.getElementById('steps-letters-calls-form-letters-calls-uplift-field');

// Call initializeForm only if all necessary elements exist
if (form && total_for_letters_and_phone_calls && letters && phone_calls) {
	initializeForm(
		form,
		total_for_letters_and_phone_calls,
		letters,
		phone_calls,
		letter_calls_uplift_checkbox,
		letter_calls_uplift_percentage
	)
};