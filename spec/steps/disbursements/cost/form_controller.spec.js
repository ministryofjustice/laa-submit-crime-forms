import {
  handleFormChange
} from '../../../../app/javascript/controllers/disbursement_cost_form_controller';

describe('Disbursement costs form', () => {
  let form;
  let valueField;
  let vatField;
  let totalWithoutVatField;
  let totalWithVatField;

  afterEach(() => {
    // Remove elements from the document
    document.body.removeChild(form);
  });

  it('should set the amounts to 0 if the value field is NaN', () => {
    setupForm('aa', 0.45, false, 0.2);

    triggerHandleFormChange(valueField)

    expect(totalWithoutVatField).toHaveProperty('innerHTML', '£0.00');
    expect(totalWithVatField).toHaveProperty('innerHTML', '£0.00');
  })

  it('should set the amounts when apply vat is not checked', () => {
    setupForm(101, 0.45, false, 0.2);

    triggerHandleFormChange(valueField)

    expect(totalWithoutVatField).toHaveProperty('innerHTML', '£45.45');
    expect(totalWithVatField).toHaveProperty('innerHTML', '£45.45');
  })

  it('should set the amount with vat based on the vat amount multipler', () => {
    setupForm(100, 0.45, true, 0.2);

    triggerHandleFormChange(valueField)

    expect(totalWithoutVatField).toHaveProperty('innerHTML', '£45.00');
    expect(totalWithVatField).toHaveProperty('innerHTML', '£54.00');
  })

  it('should multiply the value by the multipler field', () => {
    setupForm(100, 0.25, false, 0.2);

    triggerHandleFormChange(valueField)

    expect(totalWithoutVatField).toHaveProperty('innerHTML', '£25.00');
    expect(totalWithVatField).toHaveProperty('innerHTML', '£25.00');
  })

  it('should update when the vat box is changed', () => {
    setupForm(100, 0.45, false, 0.2);

    triggerHandleFormChange(vatField)

    expect(totalWithoutVatField).toHaveProperty('innerHTML', '£45.00');
    expect(totalWithVatField).toHaveProperty('innerHTML', '£45.00');
  })

  const setupForm = (value, multipler, vat, vatAmount)=> {
    // Create mock elements
    form = document.createElement('form');
    document.body.appendChild(form);

    valueField = document.createElement('input');
    valueField.setAttribute('data-selector', 'valueField');
    valueField.setAttribute('data-multipler', multipler);
    valueField.value = value;
    form.appendChild(valueField);

    vatField = document.createElement('input');
    vatField.setAttribute('data-selector', 'vatField');
    vatField.setAttribute('data-multipler', vatAmount);
    vatField.checked = vat;
    form.appendChild(vatField);

    totalWithoutVatField = document.createElement('div');
    totalWithoutVatField.setAttribute('id', 'total-without-vat')
    form.appendChild(totalWithoutVatField)

    totalWithVatField = document.createElement('div');
    totalWithVatField.setAttribute('id', 'total-with-vat')
    form.appendChild(totalWithVatField)
  }
  // Trigger handleFormChange function
  const triggerHandleFormChange = (eventTarget) => {
    const event = new Event('change')
    Object.defineProperty(event, 'target', { value: eventTarget, enumerable: true });
    handleFormChange(event);
  };

})