window.addEventListener("DOMContentLoaded", (event) => {
  const fileInput = document.querySelector('.govuk-file-upload');
  const maxFileSize = fileInput.dataset.maxSize;
  const errorHeading = fileInput.dataset.errorHeading;
  const errorMessage = fileInput.dataset.sizeErrorMessage;
  const feedback = document.querySelector(".single-file-upload__message");
  const saveButtons = document.querySelectorAll('button[type="submit"]');

  if(fileInput){
    /*
      logic for file progress indicator
      and uploaded files list
    */
    fileInput.addEventListener('change', function(event) {
        if(fileInput.files.length > 0){
          handleUploadList(fileInput);
        }
    });

    /*
      handle checking file size, if exceeds limit,
      refresh with error shown and move page to file upload section.
    */
    if (saveButtons) {
      for(const button of saveButtons) {
        button.addEventListener('click', function (event) {
          if(fileInput.files.length > 0){
            if(!validateFileSize(fileInput, maxFileSize, feedback)){
              generateFileSizeError(fileInput, errorMessage, errorHeading, feedback);
              event.preventDefault();
              event.stopImmediatePropagation();
            }
          }
        })
      }
    }
  }
});

function handleUploadList(fileInput){
  //replace selected file text
  let filenameCell = document.querySelector('.moj-multi-file-upload__filename');
  let uploadedFile = fileInput.files[0];
  if(uploadedFile && filenameCell){
    filenameCell.textContent = uploadedFile.name;
  }
}

function validateFileSize(fileInput, maxFileSize, feedback){
  if (fileInput) {
    feedback.html('');
    removeInlineError(fileInput);
    const file = fileInput.files[0];
    let validationPassed = file && (file.size <= maxFileSize)

    return validationPassed;
  }
}

function generateFileSizeError(fileInput, errorMessage, errorHeading, feedback) {
  feedback.html(govukErrorSummary(fileInput.id, errorMessage, errorHeading));
  addInlineError(fileInput, errorMessage)
  let errorSummary = document.querySelector('.govuk-error-summary');
  if(errorSummary){
    errorSummary.scrollIntoView({ behavior: 'smooth' });
    errorSummary.focus();
  }
}

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
