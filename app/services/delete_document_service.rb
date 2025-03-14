# A service to delete all documents for a draft application, in order
# to comply with GDPR.
#
# This only operates on drafts since the app store regulates the other
# submissions. For each evidence file in the claim, we destroy the
# file if it exists and then delete the object itself. We use `delete`
# here to save a round-trip from doing `.reload`.
class DeleteDocumentService
  class << self
    def call(claim_id)
      claim = Claim.find(claim_id)
      # TODO: CRM457-2398: Remove this check as it'll be redundant then
      return unless claim && claim.state == 'draft'

      evidence = claim.supporting_evidence.each do |file|
        file_uploader.destroy(file.file_path) if file_uploader.exists?(file.file_path)
        file.destroy
      end

      claim.supporting_evidence.delete(*evidence)

      claim.gdpr_documents_deleted = claim.supporting_evidence.blank?
      claim.save
    end

    private

    def file_uploader
      @file_uploader ||= FileUpload::FileUploader.new
    end
  end
end
