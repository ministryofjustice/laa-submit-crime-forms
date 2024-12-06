module Nsm
  class ImportForm < ::Steps::BaseFormObject
    include PriorAuthority::DocumentUploadable

    def supported_filetype?
      %w[text/plain application/xml text/xml].include?(Marcel::MimeType.for(file_upload.tempfile))
    end
  end
end
