module Nsm
  class ImportForm < ::Steps::BaseFormObject
    include PriorAuthority::DocumentUploadable

    attribute :file_upload
    validate :file_upload_provided

    def supported_filetype?
      %w[text/plain application/xml text/xml].include?(Marcel::MimeType.for(file_upload.tempfile))
    end

    private

    def file_upload_provided
      return if file_upload.present?

      errors.add(:file_upload, :blank)
    end
  end
end
