import MOJFrontend from '@ministryofjustice/frontend'
import $ from 'jquery'

window.$ = $

MOJFrontend.MultiFileUpload.prototype.uploadFile = function (file) {
    this.params.uploadFileEntryHook(this, file);
    let formData = new FormData();
    formData.append('documents', file);
    let fileListLength = this.feedbackContainer.find('.govuk-table__row.moj-multi-file-upload__row').length
    let item = $(this.getFileRowHtml(file, fileListLength));
    let feedback = $(".moj-multi-file-upload__message");
    this.feedbackContainer.find('.moj-multi-file-upload__list').append(item);

    $.ajax({
        url: this.params.uploadUrl,
        type: 'post',
        data: formData,
        processData: false,
        contentType: false,
        success: $.proxy(function (response) {
            feedback.html(this.getSuccessHtml(`${response.success.file_name} has been uploaded`));
            this.status.html(`${response.success.file_name} has been uploaded`);
            item.find(`a.remove-link.moj-multi-file-upload__delete`).attr("value", response.success.evidence_id ?? file.name)
            this.params.uploadFileExitHook(this, file, response);
        }, this),
        error: $.proxy(function (jqXHR, textStatus, errorThrown) {
            feedback.html(this.getErrorHtml(jqXHR.responseJSON.error.message));
            this.status.html(jqXHR.responseJSON.error.message);
            this.feedbackContainer.find(`#${fileListLength}`).remove();
            this.params.uploadFileErrorHook(this, file, jqXHR, textStatus, errorThrown);
        }, this),
        xhr: function () {
            var xhr = new XMLHttpRequest();
            xhr.upload.addEventListener('progress', function (e) {
                if (e.lengthComputable) {
                    var percentComplete = e.loaded / e.total;
                    percentComplete = parseInt(percentComplete * 100, 10);
                    item.find('.moj-multi-file-upload__progress').text(' ' + percentComplete + '%');
                }
            }, false);
            return xhr;
        }
    });
};

MOJFrontend.MultiFileUpload.prototype.getFileRowHtml = function (file, fileListLength) {
    return `<tr class="govuk-table__row moj-multi-file-upload__row" id="${fileListLength}">
            <td class="govuk-table__cell moj-multi-file-upload__filename">
                <span class="moj-multi-file-upload__filename"> ${file.name}</span>
                <span class="moj-multi-file-upload__progress">(0%)</span></td>
            <td class="govuk-table__cell moj-multi-file-upload__actions">
                <a class="remove-link moj-multi-file-upload__delete" href="#0" value="${file.name}">Remove 
                <span class="govuk-visually-hidden">${file.name}</span>
                </a>
            </td>
        </tr>`;
};

MOJFrontend.MultiFileUpload.prototype.onFileDeleteClick = function (e) {
    e.preventDefault(); // if user refreshes page and then deletes
    let button = $(e.currentTarget);
    let feedback = $(".moj-multi-file-upload__message");
    let fileName = button.parents('.govuk-table__row.moj-multi-file-upload__row').attr('id')

    $.ajax({
        url: `${this.params.deleteUrl}?evidence_id=${button.attr('value')}`,
        type: 'delete',
        success: $.proxy(function (response) {
            feedback.html(this.getSuccessHtml(`${fileName} has been deleted`));
            button.parents('.moj-multi-file-upload__row').remove();
            if (this.feedbackContainer.find('.moj-multi-file-upload__row').length === 0) {
                this.feedbackContainer.addClass('moj-hidden');
            }
            this.params.fileDeleteHook(this, response);
        }, this),
        error: $.proxy(function (jqXHR, textStatus, errorThrown) {
            feedback.html(this.getErrorHtml(jqXHR.responseJSON.error.message));
            this.status.html(jqXHR.responseJSON.error.message);
            this.params.fileDeleteHook(this, jqXHR, textStatus, errorThrown);
        }, this),
    });
};
MOJFrontend.MultiFileUpload.prototype.onDrop = function (e) {
    e.preventDefault();
    this.dropzone.removeClass('moj-multi-file-upload--dragover');
    this.feedbackContainer.removeClass('moj-hidden');
    this.status.html(this.params.uploadStatusText);
    this.uploadFiles(e.originalEvent.dataTransfer.files);
};
MOJFrontend.MultiFileUpload.prototype.onFileChange = function (e) {
    this.feedbackContainer.removeClass('moj-hidden');
    this.status.html(this.params.uploadStatusText);
    this.uploadFiles(e.currentTarget.files);
    this.fileInput.replaceWith($(e.currentTarget).val('').clone(true));
    this.setupFileInput();
    this.fileInput.focus();
};
MOJFrontend.MultiFileUpload.prototype.getSuccessHtml = function(message) {
    return `<div class="moj-banner moj-banner--success" role="region" aria-label="Success">
              <svg class="moj-banner__icon" fill="currentColor" role="presentation" focusable="false" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 25 25" height="25" width="25">
                <path d="M25,6.2L8.7,23.2L0,14.1l4-4.2l4.7,4.9L21,2L25,6.2z" />
              </svg>
              <div class="moj-banner__message">${message}</div>
              </div>`;
};

MOJFrontend.MultiFileUpload.prototype.getErrorHtml = function(message) {
    return `<div class="moj-banner moj-banner--warning" role="region" aria-label="Warning">
              <svg class="moj-banner__icon" fill="currentColor" role="presentation" focusable="false" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 25 25" height="25" width="25">
                <path d="M13.6,15.4h-2.3v-4.5h2.3V15.4z M13.6,19.8h-2.3v-2.2h2.3V19.8z M0,23.2h25L12.5,2L0,23.2z" />
              </svg>
            <div class="moj-banner__message">${message}</div>
            </div>`;

};

if (typeof MOJFrontend.MultiFileUpload !== "undefined") {
    new MOJFrontend.MultiFileUpload({
        container: $(".moj-multi-file-upload"),
        uploadUrl: window.location.href,
        deleteUrl: window.location.href
    })
}

