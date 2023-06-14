import {
	handleFormChange
} from '../../../app/javascript/controllers/letters_calls_form_controller';

describe('Letters and phone calls form', () => {
	let form;
	let totalElement;
	let lettersElement;
	let phoneCallsElement;
	let upliftCheckboxElement;
	let upliftPercentageElement;

	const createForm = () => {
		// Create mock elements
		form = document.createElement('form');
		totalElement = document.createElement('div');
		lettersElement = document.createElement('input');
		phoneCallsElement = document.createElement('input');
		upliftCheckboxElement = document.createElement('input');
		upliftPercentageElement = document.createElement('input');
		// Set element properties and attributes
		lettersElement.value = '0';
		lettersElement.setAttribute('data-rate-letters', '4.09');
		phoneCallsElement.value = '0';
		phoneCallsElement.setAttribute('data-rate-phone-calls', '4.09');
		upliftCheckboxElement.setAttribute('checked', false);
		upliftPercentageElement.value = '0';
		// Append elements to the document
		document.body.appendChild(form);
		form.appendChild(lettersElement);
		form.appendChild(phoneCallsElement);
		form.appendChild(upliftCheckboxElement);
		form.appendChild(upliftPercentageElement);
	};

	// Trigger handleFormChange function
	const triggerHandleFormChange = (event, eventTarget) => {
		Object.defineProperty(event, 'target', { value: eventTarget, enumerable: true });
		handleFormChange(
			event,
			form,
			totalElement,
			lettersElement,
			phoneCallsElement,
			upliftCheckboxElement,
			upliftPercentageElement
		);
	};

	// Set values for the form elements
	const setElementValues = (lettersValue, phoneCallsValue, upliftPercentage, upliftCheckbox) => {
		lettersElement.value = lettersValue;
		phoneCallsElement.value = phoneCallsValue;
		upliftPercentageElement.value = upliftPercentage;
		upliftCheckboxElement.checked = upliftCheckbox;
	}

	beforeEach(() => {
		// Create form with mock elements
		createForm();
	});

	afterEach(() => {
		// Remove elements from the document
		document.body.removeChild(form);
	});

	it('should not update total if only letter value changes', () => {
		// GIVEN
		setElementValues('1', '0', '0', false)
		// WHEN
		const event = new Event('change')
		triggerHandleFormChange(event, lettersElement);
		// THEN
		const expectedInnerHTML = '£0.00';
		expect(totalElement).toHaveProperty('innerHTML', expectedInnerHTML);
	});

	it('should update total if both letters and phone calls value is present', () => {
		// GIVEN
		setElementValues('1', '1', '0', true)
		// WHEN
		const event = new Event('change')
		triggerHandleFormChange(event, lettersElement);
		// THEN
		const expectedInnerHTML = '£8.18';
		expect(totalElement).toHaveProperty('innerHTML', expectedInnerHTML);
	});

	it('should update total when user enters uplift percentage and tabs out', () => {
		// GIVEN
		setElementValues('1', '1', '10', true)
		// WHEN
		const event = new Event('change', { bubbles: true })
		triggerHandleFormChange(event, upliftPercentageElement);
		// THEN
		expect(upliftPercentageElement.value).toBe('10');
		expect(upliftCheckboxElement.checked).toBe(true);
		expect(totalElement).toHaveProperty('innerHTML', '£9.00');
	});

	it('should reset percentage value if checkbox is unchecked', () => {
		// GIVEN
		setElementValues('1', '1', '20', false)
		// WHEN
		const newEvent = new Event('change')
		triggerHandleFormChange(newEvent, upliftCheckboxElement);
		// THEN
		expect(upliftCheckboxElement.checked).toBe(false);
		expect(upliftPercentageElement.value).toBe('');
		expect(totalElement).toHaveProperty('innerHTML', '£8.18');
	});
});
