function processString(string){
    //replace new lines with <br> tags to preserve formatting when displaying the string in HTML
    let new_string = string.replace(/\r?\n/g, '<br>')
    return new_string
}

function revProcessString(string){
    //replace <br> tags with new lines to preserve formatting when displaying the string in a text area
    let new_string = string.replace(/<br>/g, '\n')
    return new_string
}

const form = document.querySelector('form')
const submitButton = form.querySelector('button[type="submit"]')
const fields = form.querySelectorAll('textarea')

//replace text value on page load with reverse formatting
document.addEventListener('DOMContentLoaded', () => {
    if (!fields) return;

    fields.forEach(field => {
        if (field?.value) {
            field.value = revProcessString(field.value)
        }
    });
});
  

//sanitize text area value before submitting the form
document.addEventListener('DOMContentLoaded', () => {
    if (!fields || !submitButton) return;

    submitButton.addEventListener('click', () => {
    fields.forEach(field => {
        if (field?.value) {
        field.value = processString(field.value)
        }
    });
  });
});