# frozen_string_literal: true

module Nsm
  module Steps
    class SupportingEvidenceForm < ::Steps::BaseFormObject
      attribute :send_by_post, :boolean

      # This attribute will not reliably be populated,
      # but is needed to allow the UI to render the appropriate validation message
      attribute :supporting_evidence
      validate :supporting_evidence_provided

      private

      def persist!
        application.update!(attributes_to_update)
      end

      def supporting_evidence_provided
        return if send_by_post || application.supporting_evidence.any?

        errors.add(:supporting_evidence, :blank)
      end

      def attributes_to_update
        attrs = attributes.slice('send_by_post')
        #  reset gdpr_documents_deleted if there is any evidence on the claim regardless of
        # whether provider has added new evidence or not as a stopgap
        attrs.merge(gdpr_documents_deleted: false) if application.supporting_evidence.any?
      end
    end
  end
end
