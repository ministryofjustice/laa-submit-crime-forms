module Nsm
  class ScheduleDeleteDraftDocs < ApplicationJob
    sidekiq_options retry: 1

    def perform
      return false if filtered_claims.empty?

      filtered_claims.each do |claim|
        Nsm::DeleteDraftDocs.perform_later(claim)
      end
    end

    def filtered_claims
      # TODO: need to filter claims out if claim has previously been GDPRd
      # Claim.where(state: 'draft', updated_at: ..6.months.ago, gdpr_documents_deleted: false)

      Claim.where(state: 'draft', updated_at: ..6.months.ago)
    end
  end
end
