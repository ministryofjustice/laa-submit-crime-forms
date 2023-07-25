import MOJFrontend from '@ministryofjustice/frontend'
import $ from 'jquery'
window.$ = $

export default function initFileUpload() {
    MOJFrontend.MultiFileUpload.prototype.getFileRowHtml = function (file) {
        var html =
            `<tr class="govuk-table__row moj-multi-file-upload__row">
            <td class="govuk-table__cell moj-multi-file-upload__filename">
                <span class="moj-multi-file-upload__filename"> ${file.name}</span>
                <span class="moj-multi-file-upload__progress">(0%)</span></td>
            <td class="govuk-table__cell moj-multi-file-upload__actions">
                <a class="remove-link moj-multi-file-upload__delete" href="#0" value="${file.name}">Remove 
                <span class="govuk-visually-hidden">${file.name}</span>
                </a>
            </td>
        </tr>`

        return html;
    };

    MOJFrontend.MultiFileUpload.prototype.onFileDeleteClick = function (e) {
        e.preventDefault(); // if user refreshes page and then deletes
        var button = $(e.currentTarget);
        $.ajax({
            url: `${this.params.deleteUrl}?resource_id=${button[0].attributes[2].value}`,
            type: 'delete',
            success: $.proxy(function(response){
                if(response.error) {
                    // handle error
                } else {
                    button.parents('.moj-multi-file-upload__row').remove();
                    if(this.feedbackContainer.find('.moj-multi-file-upload__row').length === 0) {
                        this.feedbackContainer.addClass('moj-hidden');
                    }
                }
                this.params.fileDeleteHook(this, response);
            }, this)
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
    if (typeof MOJFrontend.MultiFileUpload !== "undefined") {
        new MOJFrontend.MultiFileUpload({
            container: $(".moj-multi-file-upload"),
            uploadUrl: window.location.href,
            deleteUrl: window.location.href
        })
    }


}
