const checkSvg =
`<svg class="moj-banner__icon" fill="currentColor" role="presentation" focusable="false" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 25 25" height="25" width="25">
    <path d="M25,6.2L8.7,23.2L0,14.1l4-4.2l4.7,4.9L21,2L25,6.2z"></path>
</svg>`

const failSvg =
`<svg class="moj-banner__icon" fill="currentColor" role="presentation" focusable="false" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 25 25" height="25" width="25">
  <path d="M13.6,15.4h-2.3v-4.5h2.3V15.4z M13.6,19.8h-2.3v-2.2h2.3V19.8z M0,23.2h25L12.5,2L0,23.2z"/>
</svg>`

const progress =
`<td class="govuk-table__cell moj-multi-file-upload__progress" data-label="Upload Progress">
<progress>working</progress>
</td>`


window.addEventListener("DOMContentLoaded", (event) => {
  const fileUploader = document.querySelector('.govuk-file-upload');
  const maxFileSize = fileUploader.dataset.maxSize;
  const errorHeading = fileUploader.dataset.errorHeading;
  const errorMessage = fileUploader.dataset.sizeErrorMessage;
  const feedback = $(".single-file-upload__message");
  const saveButtons = document.querySelectorAll('button[type="submit"]');

  if(fileUploader){
    /*
      logic for file progress indicator
      and uploaded files list
    */
    fileUploader.addEventListener('change', function(event) {
      handleUploadList(fileUploader);
    });

    /*
      handle checking file size, if exceeds limit,
      refresh with error shown and move page to file upload section.
    */
    if (saveButtons) {
      for(var i = 0; i < saveButtons.length; i++) {
        saveButtons[i].addEventListener('click', function (event) {
          if(!validateFileSize(fileUploader, maxFileSize, feedback)){
            generateFileSizeError(fileUploader, errorMessage, errorHeading, feedback);
            event.preventDefault();
            event.stopImmediatePropagation();
          }
        })
      }
    }
  }
});

function handleUploadList(fileUploader){
  //change upload progress to indicator
  let uploadProgressCell = document.querySelector('.moj-multi-file-upload__progress');
  uploadProgressCell.innerHTML = progress;
  //replace uploaded files text and change indicator to tick if successful
  let filenameCell = document.querySelector('.moj-multi-file-upload__filename');
  let uploadedFile = fileUploader.files[0];
  if(uploadedFile){
    filenameCell.textContent = uploadedFile.name;
    uploadProgressCell.innerHTML = checkSvg;
  }
  else{
    uploadProgressCell.innerHTML = failSvg;
  }
}

function validateFileSize(fileUploader, maxFileSize, feedback){
  if (fileUploader) {
    feedback.html('');
    removeInlineError(fileUploader);
    const file = fileUploader.files[0];

    if (file && file.size > maxFileSize) {
      return false;
    }
    else{
      return true;
    }
  }
}

function generateFileSizeError(fileUploader, errorMessage, errorHeading, feedback) {
  feedback.html(govukErrorSummary(fileUploader.id, errorMessage, errorHeading));
  addInlineError(fileUploader, errorMessage)
  errorSummary = document.querySelector('.govuk-error-summary');
  errorSummary.scrollIntoView();
  errorSummary.focus();
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
