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
        application.update!(attributes.slice('send_by_post'))
      end

      def supporting_evidence_provided
        return if send_by_post || application.supporting_evidence.any?

        errors.add(:supporting_evidence, :blank)
      end
    end
  end
end
