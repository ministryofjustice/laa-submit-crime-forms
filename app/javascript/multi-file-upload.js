import { ConfigurableComponent } from 'govuk-frontend'
import $ from 'jquery'

class MultiFileUpload extends ConfigurableComponent {
    static moduleName = 'moj-multi-file-upload'

    constructor($root, config = {}) {
        super($root, config)

        if (!MultiFileUpload.isSupported()) {
            return this
        }

        const container =
            this.config.feedbackContainer.element ??
            this.$root.querySelector(this.config.feedbackContainer.selector)

        if (!container || !(container instanceof HTMLElement)) {
            return this
        }

        this.feedbackContainer = container
        this.container = $root

        this.setupFileInput()
        this.setupDropzone()
        this.setupLabel()
        this.setupStatusBox()

        this.feedbackContainer.addEventListener('click', this.onFileDeleteClick.bind(this))
        this.container.classList.add('moj-multi-file-upload--enhanced')
    }

    setupDropzone() {
        this.dropzone = document.createElement('div')
        this.dropzone.classList.add('moj-multi-file-upload__dropzone')

        this.dropzone.addEventListener('dragover', this.onDragOver.bind(this))
        this.dropzone.addEventListener('dragleave', this.onDragLeave.bind(this))
        this.dropzone.addEventListener('drop', this.onDrop.bind(this))

        this.fileInput.replaceWith(this.dropzone)
        this.dropzone.appendChild(this.fileInput)
    }

    setupLabel() {
        const label = document.createElement('label')
        label.setAttribute('for', this.fileInput.id)
        label.classList.add('govuk-button', 'govuk-button--secondary')
        label.textContent = this.config.dropzoneButtonText

        const hint = document.createElement('p')
        hint.classList.add('govuk-body')
        hint.textContent = this.config.dropzoneHintText

        this.label = label
        this.dropzone.append(hint)
        this.dropzone.append(label)
    }

    setupFileInput() {
        this.fileInput = this.container.querySelector('.moj-multi-file-upload__input')
        this.fileInput.addEventListener('change', this.onFileChange.bind(this))
        this.fileInput.addEventListener('focus', this.onFileFocus.bind(this))
        this.fileInput.addEventListener('blur', this.onFileBlur.bind(this))
    }

    setupStatusBox() {
        this.status = document.createElement('div')
        this.status.classList.add('govuk-visually-hidden')
        this.status.setAttribute('aria-live', 'polite')
        this.status.setAttribute('role', 'status')
        this.dropzone.append(this.status)
    }

    onDragOver(event) {
        event.preventDefault()
        this.dropzone.classList.add('moj-multi-file-upload--dragover')
    }

    onDragLeave() {
        this.dropzone.classList.remove('moj-multi-file-upload--dragover')
    }

    onDrop(event) {
        event.preventDefault()

        this.dropzone.classList.remove('moj-multi-file-upload--dragover')
        this.feedbackContainer.classList.remove('moj-hidden')
        this.status.innerHTML = this.config.uploadStatusText
        this.uploadFiles(event.dataTransfer.files)
    }

    onFileChange(event) {
        this.feedbackContainer.classList.remove('moj-hidden')
        this.status.innerHTML = this.config.uploadStatusText

        this.uploadFiles(this.fileInput.files)

        const newInput = event.currentTarget.cloneNode(true)
        newInput.value = ''
        event.currentTarget.replaceWith(newInput)

        this.setupFileInput()
        this.fileInput.focus()
    }

    async uploadFiles(files) {
        const saveButtons = document.querySelectorAll('button[type="submit"]')

        saveButtons.forEach(button => {
            button.disabled = true
            button.setAttribute('aria-disabled', 'true')
        })

        try {
            await Promise.all([...files].map(file => this.uploadFile(file)))
        } finally {
            saveButtons.forEach(button => {
                button.disabled = false
                button.setAttribute('aria-disabled', 'false')
            })
        }
    }

    onFileFocus() {
        this.label.classList.add('moj-multi-file-upload--focused')
    }

    onFileBlur() {
        this.label.classList.remove('moj-multi-file-upload--focused')
    }

    getFileRowHtml(file, fileListLength) {
        return `
        <tr class="govuk-table__row moj-multi-file-upload__row" id="${fileListLength}">
            <td class="govuk-table__cell moj-multi-file-upload__filename" data-label="File name">
                <span class="file-name">${file.name}</span>
            </td>
            <td class="govuk-table__cell moj-multi-file-upload__progress" data-label="Upload Progress">
                <progress>working</progress>
            </td>
            <td class="govuk-table__cell moj-multi-file-upload__actions">
                <a class="remove-link moj-multi-file-upload__delete govuk-!-display-none" href="#0" value="${file.name}">
                    Delete <span class="govuk-visually-hidden">${file.name}</span>
                </a>
            </td>
        </tr>`
    }

    getSuccessIcon() {
        return `
        <svg class="moj-alert__icon" role="presentation" focusable="false" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 30 30" height="30" width="30">
          <path d="M11.2869 24.6726L2.00415 15.3899L4.62189 12.7722L11.2869 19.4186L25.3781 5.32739L27.9958 7.96369L11.2869 24.6726Z" fill="currentColor" />
        </svg>`
    }

    getSuccessHtml(message) {
        return `
        <div role="region" class="moj-alert moj-alert--success" aria-label="success: Upload successful" data-module="moj-alert">
        <div>${this.getSuccessIcon()} </div>
          <div class="moj-alert__content">${message}</div>
        </div>`
    }

    getErrorIcon() {
        return `
        <svg class="moj-alert__icon" role="presentation" focusable="false" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 30 30" height="30" width="30">
            <path fill-rule="evenodd" clip-rule="evenodd" d="M20.1777 2.5H9.82233L2.5 9.82233V20.1777L9.82233 27.5H20.1777L27.5 20.1777V9.82233L20.1777 2.5ZM10.9155 8.87769L15.0001 12.9623L19.0847 8.87771L21.1224 10.9154L17.0378 15L21.1224 19.0846L19.0847 21.1222L15.0001 17.0376L10.9155 21.1223L8.87782 19.0846L12.9624 15L8.87783 10.9153L10.9155 8.87769Z" fill="currentColor" />
        </svg>`
    }
    getErrorHtml(message) {
        return `
        <div role="region" class="moj-alert moj-alert--error" aria-label="error: This case has been assigned to someone else" data-module="moj-alert">
        <div>${this.getErrorIcon()}</div>
          <div class="moj-alert__content">This case has been assigned to someone else, so you can no longer make changes.</div>
        </div>
        `
    }

    getDeleteButton(file) {
        const button = document.createElement('button')

        button.setAttribute('type', 'button')
        button.setAttribute('name', 'delete')
        button.setAttribute('value', file.filename)

        button.classList.add(
            'moj-multi-file-upload__delete',
            'govuk-button',
            'govuk-button--secondary',
            'govuk-!-margin-bottom-0'
        )

        button.innerHTML = `Delete <span class="govuk-visually-hidden">${file.originalname}</span>`

        return button
    }

    uploadFile(file) {
        $(this.feedbackContainer).find('.govuk-table').removeClass("moj-hidden");
        const maxFileSize = document.querySelector('.moj-multi-file-upload').dataset.maxSize;
        let formData = new FormData();
        formData.append('documents', file);
        let fileListLength = $(this.feedbackContainer).find('.govuk-table__row.moj-multi-file-upload__row').length;
        let fileRow = $(this.getFileRowHtml(file, fileListLength));
        let feedback = $(".moj-multi-file-upload__message");
        $(this.feedbackContainer).find('.moj-multi-file-upload__list').append(fileRow);

        if (file.size > maxFileSize) {
            feedback.html(this.getErrorHtml('File size is too big. Unable to upload.'));
            fileRow.find('progress').replaceWith(this.getErrorIcon());
            return Promise.reject(new Error('file, ' + file.name + ', size too big: ' + file.size + ' > ' + maxFileSize));
        }

        return $.ajax({
            url: this.config.uploadUrl,
            type: 'post',
            data: formData,
            processData: false,
            contentType: false,

            success: function (response) {
                feedback.html(this.getSuccessHtml(`${response.success.file_name} has been uploaded`));
                this.status.innerHTML = `${response.success.file_name} has been uploaded`;
                fileRow.find(`a.remove-link.moj-multi-file-upload__delete`).attr("value", response.success.evidence_id ?? file.name);
                fileRow.find(`a.remove-link.moj-multi-file-upload__delete`).removeClass('govuk-!-display-none');
                fileRow.find('progress').replaceWith(this.getSuccessIcon());
            }.bind(this),

            error: function (jqXHR, textStatus, errorThrown) {
                let errorMessage = jqXHR.responseJSON?.error.message;
                if (errorMessage) {
                    feedback.html(this.getErrorHtml(errorMessage));
                    this.status.innerHTML = errorMessage;
                }
                fileRow.find('progress').replaceWith(this.getSuccessIcon());
            }.bind(this),
        });
    }

    onFileDeleteClick(event) {
        event.preventDefault()

        const target = event.target
        if (!target.classList.contains('moj-multi-file-upload__delete') &&
            !target.closest('.moj-multi-file-upload__delete')) {
            return
        }

        const deleteLink = target.classList.contains('moj-multi-file-upload__delete')
            ? target
            : target.closest('.moj-multi-file-upload__delete')

        const row = deleteLink.closest('.govuk-table__row.moj-multi-file-upload__row')
        const table = row.closest('.govuk-table')
        const feedback = document.querySelector(".moj-multi-file-upload__message")

        const visibleRows = table.querySelectorAll('.govuk-table__row.moj-multi-file-upload__row:not(.moj-hidden)')
        if (visibleRows.length === 1) {
            table.classList.add("moj-hidden")
        }

        row.classList.add("moj-hidden")

        const fileName = row.querySelector('.moj-multi-file-upload__filename').textContent.trim()

        $.ajax({
            url: this.config.deleteUrl,
            type: 'delete',
            data: { evidence_id: deleteLink.getAttribute('value') },

            success: (response) => {
                feedback.innerHTML = this.getSuccessHtml(`${fileName} has been deleted`)
                row.remove()

                if (this.feedbackContainer.querySelectorAll('.moj-multi-file-upload__row').length === 0) {
                    this.feedbackContainer.classList.add('moj-hidden')
                }
            },

            error: (jqXHR, textStatus, errorThrown) => {
                if (errorThrown !== "") {
                    row.classList.remove("moj-hidden")
                    table.classList.remove("moj-hidden")
                }

                const errorMessage = jqXHR.responseJSON?.error.message
                if (errorMessage) {
                    feedback.innerHTML = this.getErrorHtml(errorMessage)
                    this.status.innerHTML = errorMessage
                }
            }
        })
    }

    static isSupported() {
        return (
            this.isDragAndDropSupported() &&
            this.isFormDataSupported() &&
            this.isFileApiSupported()
        )
    }

    static isDragAndDropSupported() {
        const div = document.createElement('div')
        return typeof div.ondrop !== 'undefined'
    }

    static isFormDataSupported() {
        return typeof FormData === 'function'
    }

    static isFileApiSupported() {
        const input = document.createElement('input')
        input.type = 'file'
        return typeof input.files !== 'undefined'
    }

    static defaults = Object.freeze({
        uploadStatusText: 'Uploading files, please wait',
        dropzoneHintText: 'Drag and drop files here or',
        dropzoneButtonText: 'Choose files',
        feedbackContainer: {
            selector: '.moj-multi-file__uploaded-files'
        }
    })

    static schema = Object.freeze({
        properties: {
            uploadUrl: { type: 'string' },
            deleteUrl: { type: 'string' },
            uploadStatusText: { type: 'string' },
            dropzoneHintText: { type: 'string' },
            dropzoneButtonText: { type: 'string' }
        }
    })
}

document.addEventListener('DOMContentLoaded', () => {
    if (typeof MultiFileUpload !== "undefined") {
        const element = document.querySelector(
            '[data-module="moj-multi-file-upload"]'
        )

        if (element) {
            const multiFileUpload = new MultiFileUpload(element, {
                uploadUrl: window.location.href,
                deleteUrl: window.location.href
            })
        }
    }
})

$(function() {
    // always pass csrf tokens on ajax calls
    $.ajaxSetup({
        headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') }
    })
})
