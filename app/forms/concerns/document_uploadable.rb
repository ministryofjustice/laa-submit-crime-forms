# This concern expects there to be a method called document that returns
# the appropriate SupportingDocument object
# It will handle validation automatically, but you will need to call `save_file` in your
# `persist` method to get it to actually upload it and persist the metadata. You will
# also need to remove 'file_upload' from your attribute_names
module DocumentUploadable
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
    return true if file_upload.blank?

    file_path = file_uploader.upload(file_upload)
    save_file_metadata(file_path)
    true
  rescue StandardError => e
    Sentry.capture_exception(e)
    errors.add(:file_upload, :upload_failed)
    false
  end

  def save_file_metadata(file_path)
    document.update!(
      document_type: SupportingDocument::SUPPORTED_FILE_TYPES,
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
      errors.add(:file_upload, I18n.t('shared.shared_upload_errors.attachment_too_large',
                                      size: FileUpload::FileUploader.human_readable_max_file_size))
    elsif !supported_filetype?
      errors.add(:file_upload, :forbidden_document_type)
    elsif suspected_malware?
      errors.add(:file_upload, :suspected_malware)
    end
  end

  def handle_no_upload
    return if document_already_uploaded? || file_is_optional?

    errors.add(:file_upload, :blank)
  end

  def file_size_within_limit?
    file_upload.tempfile.size <= ENV.fetch('MAX_UPLOAD_SIZE_BYTES', nil).to_i
  end

  def supported_filetype?
    SupportedFileTypes::SUPPORTED_FILE_TYPES.include? file_upload.content_type
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
