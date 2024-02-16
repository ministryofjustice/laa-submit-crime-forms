module PriorAuthority
  # This concern expects there to be a method called document that returns
  # the appropriate SupportingDocument object
  # It will handle validation automatically, but you will need to call `save_file` in your
  # `persist` method to get it to actually upload it and persist the metadata. You will
  # also need to remove 'file_upload' from your attribute_names
  module DocumentUploader
    extend ActiveSupport::Concern

    included do
      attribute :file_upload
      validate :validate_uploaded_file
    end

    def document_already_uploaded?
      document.file_name.present?
    end

    private

    def file_is_optional?
      false
    end

    def save_file
      return if file_upload.blank?

      file_path = file_uploader.upload(file_upload)
      save_file_metadata(file_path)
    end

    def save_file_metadata(file_path)
      document.update!(
        document_type: SupportingDocument::QUOTE_DOCUMENT,
        file_name: file_upload.original_filename,
        file_type: file_upload.content_type,
        file_size: file_upload.tempfile.size,
        file_path: file_path
      )
    end

    def validate_uploaded_file
      if file_upload.nil?
        handle_no_upload
      elsif !file_size_within_limit?
        add_file_upload_error(I18n.t('shared.shared_upload_errors.file_size_limit', max_size: '20MB'))
      elsif !supported_filetype?
        add_file_upload_error(I18n.t('shared.shared_upload_errors.file_type',
                                     file_types: I18n.t('shared.shared_upload_errors.file_types')))
      elsif suspected_malware?
        add_file_upload_error(I18n.t('shared.shared_upload_errors.malware'))
      end
    end

    def handle_no_upload
      return if document_already_uploaded? || file_is_optional?

      add_file_upload_error(I18n.t('shared.shared_upload_errors.file_not_present', file: 'primary quote'))
    end

    def add_file_upload_error(string)
      errors.add(:file_upload, string)
    end

    def file_size_within_limit?
      file_upload.tempfile.size <= ENV.fetch('MAX_UPLOAD_SIZE_BYTES', nil).to_i
    end

    def supported_filetype?
      SupportedFileTypes::QUOTE_DOCUMENT.include? file_upload.content_type
    end

    def suspected_malware?
      file_uploader.scan_file(file_upload)
      false
    rescue FileUpload::FileUploader::PotentialMalwareError
      true
    end

    def file_uploader
      @file_uploader ||= FileUpload::FileUploader.new
    end
  end
end
