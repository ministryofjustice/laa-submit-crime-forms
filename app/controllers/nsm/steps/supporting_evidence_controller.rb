# frozen_string_literal: true

module Nsm
  module Steps
    class SupportingEvidenceController < Nsm::Steps::BaseController
      skip_before_action :verify_authenticity_token
      before_action :supporting_evidence

      SUPPORTED_FILE_TYPES = %w[
        application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document
        application/rtf image/jpeg image/bmp image/png image/tiff application/pdf
      ].freeze

      def edit
        @form_object = SupportingEvidenceForm.build(
          current_application
        )
      end

      def create
        unless supported_filetype(params[:documents])
          return return_error(nil, { message: 'Incorrect file type provided' })
        end

        evidence = upload_file(params)
        return_success({ evidence_id: evidence.id, file_name: params[:documents].original_filename })
      rescue FileUpload::FileUploader::PotentialMalwareError => e
        return_error(e, { message: 'File potentially contains malware so cannot be uploaded. ' \
                                   'Please contact your administrator' })
      rescue StandardError => e
        return_error(e, { message: 'Unable to upload file at this time' })
      end

      def update
        update_and_advance(SupportingEvidenceForm, as: :supporting_evidence)
      end

      def destroy
        evidence = current_application.supporting_evidence.find_by(id: params[:evidence_id])
        file_uploader.destroy(evidence.file_path)
        evidence.destroy

        return_success({ deleted: true })
      rescue StandardError => e
        return_error(e, { message: 'Unable to delete file at this time' })
      end

      def download
        render layout: 'printing'
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

      def upload_file(params)
        file_path = file_uploader.upload(params[:documents])
        save_evidence_data(params[:documents], file_path)
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

      def supported_filetype(params)
        SUPPORTED_FILE_TYPES.include? params.content_type
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
end
