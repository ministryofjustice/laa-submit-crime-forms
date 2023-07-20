# frozen_string_literal: true

module Steps
  class SupportingEvidenceController < Steps::BaseStepController
    include S3FileUploadHelper
    skip_before_action :verify_authenticity_token
    def edit
      @form_object = SupportingEvidenceForm.build(
        supporting_evidence,
        application: current_application
      )
    end

    def create
      evidence = SupportingEvidence.create(
        file_name: params[:documents].original_filename,
        file_type: params[:documents].content_type,
        file_size: params[:documents].tempfile.size,
        case_id: params[:id],
        claim: current_application
      )

      upload_evidence("#{params[:id]}/#{evidence.id}")
    end

    def update
      update_and_advance(SupportingEvidenceForm)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end

    def supporting_evidence
      @supporting_evidence ||= latest_evidence.nil? ? SupportingEvidence.new : latest_evidence
    end

    def latest_evidence
      SupportingEvidence.find_by claim_id: current_application.id
    end
  end
end

