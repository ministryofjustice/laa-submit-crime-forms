module Nsm
  class DeleteDraftDocs < ApplicationJob
    after_perform do |job|
      # assuming DeleteService is flagging GDPR docs deleted
      Rails.logger "GDPR delete supporting docs for draft NSM claim : #{claim.id}"
    end

    def perform(claim)
      # LaaCrimeFormsCommon::NSM::DeleteDocumentService.call(claim)
    end
  end
end
