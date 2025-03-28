module Nsm
  class ImportForm < ::Steps::BaseFormObject
    include PriorAuthority::DocumentUploadable

    attribute :file_upload
    validate :file_upload_provided
    validate :correct_filetype

    def supported_filetype?
      return false unless file_upload.present?
      %w[text/plain application/xml text/xml].include?(Marcel::MimeType.for(file_upload.tempfile))
    end

    private

    def file_upload_provided
      return if file_upload.present?

      errors.add(:file_upload, :blank)
    end

    def correct_filetype
      return if supported_filetype?

      errors.add(:file_upload, :forbidden_document_type)
    end
  end
end
