# frozen_string_literal: true

module Steps
  class SupportingEvidenceController < Steps::BaseStepController
    include S3FileUploadHelper
    skip_before_action :verify_authenticity_token
    before_action :supporting_evidence
    def edit
      @form_object = SupportingEvidenceForm.build(
        current_application
      )
    end

    def create
      evidence = SupportingEvidence.create(
        file_name: params[:documents].original_filename,
        file_type: params[:documents].content_type,
        file_size: params[:documents].tempfile.size,
        claim: current_application
      )

      evidence.file.attach(params[:documents])
    end

    def update
      update_and_advance(SupportingEvidenceForm, as: :supporting_evidence)
    end

    def destroy
      SupportingEvidence.destroy(params[:resource_id])
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end

    def supporting_evidence
      @supporting_evidence ||= latest_evidence.nil? ? SupportingEvidence.new : latest_evidence
    end

    def latest_evidence
      SupportingEvidence.where(claim_id: current_application.id).map
    end

    def additional_params
      [:resource_id]
    end
  end
end
