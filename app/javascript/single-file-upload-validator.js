// A basic file size validator to block single file uploads over
// a specified size.
//
window.addEventListener("DOMContentLoaded", (event) => {
  const fileUploader = document.querySelector('.govuk-file-upload');
  const maxFileSize = fileUploader.dataset.maxSize;
  const errorHeading = fileUploader.dataset.errorHeading;
  const errorMessage = fileUploader.dataset.sizeErrorMessage;
  const feedback = $(".single-file-upload__message");
  const saveButtons = document.querySelectorAll('button[type="submit"]');

  if (saveButtons) {
    for(var i = 0; i < saveButtons.length; i++) {
      saveButtons[i].addEventListener('click', function (event) {

        if (fileUploader) {
          feedback.html('');
          removeInlineError(fileUploader);
          const file = fileUploader.files[0]

          if (file && file.size > maxFileSize) {
            feedback.html(govukErrorSummary(fileUploader.id, errorMessage, errorHeading));
            addInlineError(fileUploader, errorMessage)
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

function addInlineError(element, message) {
  element.classList.add('govuk-file-upload--error');
  const group = element.closest('.govuk-form-group');
  group.classList.add('govuk-form-group--error')
  group.insertBefore(govukInlineError(message), element);
}

function removeInlineError(element) {
  element.classList.remove('govuk-file-upload--error');
  const group = element.closest('.govuk-form-group');
  group.classList.remove('govuk-form-group--error')
  group.querySelector('.govuk-error-message')?.remove();
}

function govukInlineError(message) {
  let messageElement = document.createElement('p')
  messageElement.classList.add('govuk-error-message');
  messageElement.innerHTML = `<span class="govuk-visually-hidden">Error:</span>${message}`
  return messageElement;
}

function govukErrorSummary (anchor, message, heading) {
  return `<div class="govuk-error-summary" data-module="govuk-error-summary">
            <div role="alert"><h2 class="govuk-error-summary__title">${heading}</h2>
              <div class="govuk-error-summary__body">
                <ul class="govuk-list govuk-error-summary__list">
                  <li>
                    <a data-turbo="false" href="#${anchor}">${message}</a>
                  </li>
                </ul>
              </div>
            </div>
          </div>`
};
