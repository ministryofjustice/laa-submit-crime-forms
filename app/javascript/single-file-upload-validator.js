// A basic file size validator to block single file uploads over
// a specified size.
//
window.addEventListener("DOMContentLoaded", (event) => {
  const fileUploader = document.querySelector('.govuk-file-upload');
  const maxFileSize = fileUploader.dataset.maxSize;
  const feedback = $(".single-file-upload__message");

  if (fileUploader) {
    fileUploader.addEventListener('change', function (event) {
      event.preventDefault()
      feedback.html('');
      const file = event.target.files[0]

      if (file && file.size > maxFileSize) {
        event.target.value = null
        feedback.html(getErrorHtml("The file " + file.name + " is too big. Unable to upload."));
      }
    })
  }
});

function getErrorHtml (message) {
  return `<div class="moj-banner moj-banner--warning" role="region" aria-label="Warning">
            <svg class="moj-banner__icon" fill="currentColor" role="presentation" focusable="false" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 25 25" height="25" width="25">
              <path d="M13.6,15.4h-2.3v-4.5h2.3V15.4z M13.6,19.8h-2.3v-2.2h2.3V19.8z M0,23.2h25L12.5,2L0,23.2z" />
            </svg>
          <div class="moj-banner__message">${message}</div>
          </div>`;
};
