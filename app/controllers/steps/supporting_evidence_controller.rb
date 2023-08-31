# frozen_string_literal: true

module Steps
  class SupportingEvidenceController < Steps::BaseStepController
    skip_before_action :verify_authenticity_token
    before_action :supporting_evidence, :file_uploader

    SUPPORTED_FILE_TYPES = %w[application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document
                              application/rtf image/jpeg image/bmp image/png image/tiff application/pdf].freeze

    def edit
      @form_object = SupportingEvidenceForm.build(
        current_application
      )
    end

    def create
      unless SUPPORTED_FILE_TYPES.include? params[:documents].content_type
        return return_error(nil, { message: 'Incorrect file type provided' })
      end

      file_path = @file_uploader.upload(params[:documents])
      evidence = save_evidence_data(params[:documents], file_path)
      return_success({ evidence_id: evidence.id, file_name: params[:documents].original_filename })
    rescue StandardError => e
      return_error(e, { message: 'Unable to upload file at this time' })
    end

    def update
      update_and_advance(SupportingEvidenceForm, as: :supporting_evidence)
    end

    def destroy
      evidence = SupportingEvidence.find_by(id: params[:evidence_id])
      @file_uploader.destroy(evidence.file_path)
      evidence.destroy

      return_success({ deleted: true })
    rescue StandardError => e
      return_error(e, { message: 'Unable to delete file at this time' })
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

    def save_evidence_data(params, file_path)
      SupportingEvidence.create(
        file_name: params.original_filename,
        file_type: params.content_type,
        file_size: params.tempfile.size,
        claim: current_application,
        file_path: file_path
      )
    end

    def return_success(dict)
      render json: {
        success: dict
      }, status: :ok
    end

    def return_error(exception, dict)
      Sentry.capture_exception(exception)
      render json: {
        error: dict
      }, status: :bad_request
    end
  end
end
