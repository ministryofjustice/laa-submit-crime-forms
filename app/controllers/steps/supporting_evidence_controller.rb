# frozen_string_literal: true

module Steps
  class SupportingEvidenceController < Steps::BaseStepController
    skip_before_action :verify_authenticity_token
    before_action :supporting_evidence, :file_uploader
    def edit
      @form_object = SupportingEvidenceForm.build(
        current_application
      )
    end

    def create
      file_path = @file_uploader.upload(params[:documents])
      evidence = save_evidence_data(params[:documents].original_filename, params[:documents].content_type,
                                    params[:documents].tempfile.size, file_path)
      return_success({ evidence_id: evidence.id })
    rescue StandardError => e
      return_error(e)
    end

    def update
      update_and_advance(SupportingEvidenceForm, as: :supporting_evidence)
    end

    def destroy
      @file_uploader.destroy(SupportingEvidence.find_by(id: params[:evidence_id]).file_path)
      SupportingEvidence.destroy(params[:evidence_id])

      return_success({ deleted: true })
    rescue StandardError => e
      return_error(e)
    end

    private

    def decision_tree_class
      Decisions::DecisionTree
    end

    def supporting_evidence
      @supporting_evidence = SupportingEvidence.where(claim_id: current_application.id)
    end

    def file_uploader
      @file_uploader ||= FileUpload::FileUploader.new
    end

    def save_evidence_data(original_filename, content_type, size, file_path)
      SupportingEvidence.create(
        file_name: original_filename,
        file_type: content_type,
        file_size: size,
        claim: current_application,
        file_path: file_path
      )
    end

    def return_success(dict)
      render json: {
        success: dict
      }, status: :ok
    end

    def return_error(exception)
      Sentry.capture_exception(exception)
      render json: {
        error: ''
      }, status: :bad_request
    end
  end
end
