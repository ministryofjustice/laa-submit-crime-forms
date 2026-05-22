function stringProcessor(string){
    //replace new lines with <br> tags to preserve formatting when displaying the string in HTML
    string.replace("/\n/g", '<br>')
    return string
}

//sanitize text area value before submitting the form
document.addEventListener('DOMContentLoaded', () => {
  const form = document.querySelector('form')
  const submitButton = form.querySelector('button[type="submit"]')
  const fields = form.querySelectorAll('textarea')

  if (!form || !submitButton || !fields) return;

  submitButton.addEventListener('click', () => {
    fields.forEach(field => {
      if (field?.value) {
        field.value = encodeURIComponent(field.value)
      }
    });
  });
});