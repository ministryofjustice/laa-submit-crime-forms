// A basic file size validator to block single file uploads over
// a specified size.
//
window.addEventListener("DOMContentLoaded", (event) => {
  const fileUploader = document.querySelector('.govuk-file-upload');
  const maxFileSize = fileUploader.dataset.maxSize;
  const humanMaxFileSize = (maxFileSize / 1024 / 1024).toFixed(0)
  const feedback = $(".single-file-upload__message");
  const saveButtons = document.querySelectorAll('button[type="submit"]');

  if (saveButtons) {
    for(var i = 0; i < saveButtons.length; i++) {
      saveButtons[i].addEventListener('click', function (event) {

        // error if an uploaded file is larger than permitted
        if (fileUploader) {
          feedback.html('');
          const file = fileUploader.files[0]

          if (file && file.size > maxFileSize) {
            feedback.html(govukErrorSummary('link-todo', `The selected file must be smaller than ${humanMaxFileSize}MB`));
            errorSummary = document.querySelector('.govuk-error-summary');
            errorSummary.scrollIntoView();
            errorSummary.focus();
            event.preventDefault();
            event.stopImmediatePropagation()
          }
        }
      })
    }
  }
});

function govukErrorSummary (href, message) {
  return `<div class="govuk-error-summary" data-module="govuk-error-summary">
            <div role="alert"><h2 class="govuk-error-summary__title">There is a problem on this page</h2>
              <div class="govuk-error-summary__body">
                <ul class="govuk-list govuk-error-summary__list">
                  <li>
                    <a data-turbo="false" href="#${href}">${message}</a>
                  </li>
                </ul>
              </div>
            </div>
          </div>`
};

// function addErrorMessage (msg) {
//   // this adds an error message to the gov uk error summary and shows the errors
//   const errorSummary = document.querySelector('.govuk-error-summary')
//   const ul = errorSummary.querySelector('ul')
//   const li = document.createElement('li')
//   const a = document.createElement('a')
//   li.appendChild(a)
//   ul.appendChild(li)

//   // add text and link to field
//   a.innerText += msg
//   a.setAttribute('aria-label', msg)
//   a.setAttribute('data-turbolinks', false) # NOT NEEDED?
//   a.setAttribute('href', '#dz-upload-button') # TODO

//   // show error message on the dropzone form field
//   const dropzoneElem = document.querySelector('#dropzone-form-group')
//   dropzoneElem.classList.add('govuk-form-group--error')
//   const fieldErrorMsg = document.querySelector('#dropzone-file-error')
//   const div = document.createElement('div')
//   div.innerText = msg
//   fieldErrorMsg.appendChild(div)
//   fieldErrorMsg.classList.remove('hidden')

//   // show the error summary and move focus to it
//   errorSummary.classList.remove('hidden')
//   errorSummary.scrollIntoView()
//   errorSummary.focus()
// }
